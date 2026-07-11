# Architecture — Grand Frère Vendor

Ce document explique comment le projet est structuré, pourquoi, et comment les pièces s'assemblent.

---

## 1. La philosophie générale : Clean Architecture

Le projet suit la **Clean Architecture** (architecture propre). L'idée centrale est simple :

> Le code métier ne doit jamais dépendre des détails techniques (API, base de données, framework UI).

Pour ça, on coupe le code en **3 couches** qui ne peuvent communiquer que dans un seul sens :

```
UI (widgets, pages)
    ↓ appelle
Domaine (règles métier)
    ↓ appelle
Data (API, stockage)
```

La couche du bas ne connaît pas celle du dessus. Concrètement :
- La couche **Data** (API) ne sait pas qu'il y a des widgets.
- La couche **Domaine** ne sait pas si les données viennent d'une API REST, d'une base SQLite ou d'un fichier JSON.
- La couche **UI** ne sait pas comment les données sont récupérées.

---

## 2. Structure du projet (feature-first)

Plutôt que d'organiser par type de fichier (`models/`, `controllers/`...), on organise **par fonctionnalité** :

```
lib/
├── core/                        ← Code partagé par toutes les features
│   ├── di/injection.dart        ← Injection de dépendances (GetIt)
│   ├── network/api_client.dart  ← Client HTTP (Dio)
│   ├── router/app_router.dart   ← Navigation (GoRouter)
│   ├── theme/                   ← Design system (couleurs, typo, spacing)
│   └── error/failure.dart       ← Types d'erreurs partagés
│
└── features/
    ├── auth/                    ← Connexion, inscription, mot de passe
    ├── vendor/                  ← Profil vendeur, balance, stats
    ├── orders/                  ← Commandes
    ├── menu/                    ← Articles du menu
    ├── balance/                 ← Solde et retraits
    ├── notifications/           ← Notifications
    ├── cashin/                  ← Encaissement QR
    └── shell/                   ← Shell principal (barre de navigation)
```

Chaque feature est elle-même découpée en 3 couches :

```
features/vendor/
├── domain/
│   ├── entities/vendor.dart              ← Objet métier pur (pas de JSON, pas de Flutter)
│   └── repositories/vendor_repository.dart  ← Contrat abstrait (interface)
│
├── data/
│   ├── models/vendor_model.dart          ← Sait lire le JSON + convertir en entité
│   ├── datasources/vendor_remote_datasource.dart  ← Appels HTTP réels
│   └── repositories/vendor_repository_impl.dart   ← Implémentation du contrat
│
└── presentation/
    ├── cubit/vendor_cubit.dart           ← Logique d'état (BLoC/Cubit)
    ├── cubit/vendor_state.dart           ← États possibles
    └── pages/home_screen.dart            ← Widget de la page
```

---

## 3. L'injection de dépendances (DI)

### Pourquoi en a-t-on besoin ?

Regarde `VendorCubit` :

```dart
class VendorCubit extends Cubit<VendorState> {
  VendorCubit(this._repo) : super(const VendorInitial());
  final VendorRepository _repo;
  // ...
}
```

`VendorCubit` a besoin d'un `VendorRepository` pour fonctionner. Mais il ne sait pas (et ne veut pas savoir) comment ce repository est construit.

Sans injection de dépendances, on serait obligé d'écrire partout :

```dart
// Très mauvais : le cubit connaît tous les détails techniques
final cubit = VendorCubit(
  VendorRepositoryImpl(
    VendorRemoteDataSourceImpl(
      ApiClient(
        AuthInterceptor(TokenStorage(), AuthStatus())
      )
    )
  )
);
```

C'est illisible, et surtout : si tu changes `ApiClient`, tu dois tout modifier partout.

### La solution : GetIt

**GetIt** est un **service locator** — c'est un registre global où l'on enregistre tous les objets une seule fois, et où n'importe qui peut les récupérer.

```dart
// lib/core/di/injection.dart

final getIt = GetIt.instance; // Le registre global

void configureDependencies() {
  // On enregistre chaque dépendance UNE SEULE FOIS
  getIt.registerLazySingleton(() => TokenStorage());
  getIt.registerLazySingleton(() => ApiClient(getIt<AuthInterceptor>()));
  getIt.registerLazySingleton<VendorRepository>(
    () => VendorRepositoryImpl(getIt<VendorRemoteDataSource>()),
  );
  // ...
}
```

Et dans `main.dart`, on appelle `configureDependencies()` au démarrage, avant `runApp` :

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();        // Charge les variables d'environnement (.env)
  configureDependencies();    // ← Construit le graphe de dépendances
  runApp(const App());
}
```

Ensuite, n'importe où dans le code, on peut récupérer une instance :

```dart
final vendorCubit = getIt<VendorCubit>();
final apiClient = getIt<ApiClient>();
```

### Les 3 types d'enregistrement

#### `registerLazySingleton` — Une instance, créée à la demande

```dart
getIt.registerLazySingleton(() => ApiClient(getIt<AuthInterceptor>()));
```

- L'objet est créé **la première fois** qu'on appelle `getIt<ApiClient>()`.
- Les appels suivants retournent **toujours la même instance**.
- Utilisé pour : `ApiClient`, `TokenStorage`, `AuthInterceptor`, les repositories, les datasources.
- **Pourquoi ?** Ces objets n'ont pas d'état qui change selon l'écran. Un seul client HTTP suffit pour toute l'app.

#### `registerSingleton` — Une instance, créée immédiatement

```dart
getIt.registerSingleton(VendorCubit(getIt<VendorRepository>()));
getIt.registerSingleton(OrdersCubit(getIt<OrdersRepository>()));
```

- L'objet est créé **dès l'appel de `configureDependencies()`**, sans attendre.
- Utilisé pour les cubits **globaux** (VendorCubit, OrdersCubit, ItemsCubit, NotificationsCubit).
- **Pourquoi singleton et pas lazy ?** Ces cubits doivent être chargés dès le démarrage de l'app. On veut qu'ils existent avant même que l'écran principal s'affiche.

#### `registerFactory` — Une nouvelle instance à chaque appel

```dart
getIt.registerFactory(() => LoginBloc(getIt<AuthRepository>()));
getIt.registerFactory(() => CashinCubit(getIt<CashinRepository>()));
```

- **Chaque** `getIt<LoginBloc>()` crée un **nouvel objet**.
- Utilisé pour les BLoCs d'écrans ponctuels (login, cashin, forgot password).
- **Pourquoi ?** Ces écrans ont un état local (formulaires, étapes) qui ne doit pas persister entre les visites. Si l'utilisateur quitte l'écran login et y revient, il faut un BLoC vide.

---

## 4. Le pattern BLoC / Cubit

### Principe

BLoC (Business Logic Component) sépare la **logique** des **widgets**. Le widget ne sait pas comment les données arrivent — il réagit juste aux états.

```
Widget → émet un événement ou appelle une méthode → Cubit
Cubit  → appelle le repository → reçoit les données
Cubit  → émet un nouvel état
Widget → reconstruit automatiquement
```

### Cubit vs Bloc

Dans ce projet, on utilise principalement des **Cubit** (version simplifiée de Bloc sans events) :

```dart
// Cubit : on appelle directement des méthodes
class VendorCubit extends Cubit<VendorState> {
  VendorCubit(this._repo) : super(const VendorInitial());

  Future<void> load() async {
    emit(const VendorLoading());           // État : chargement
    final result = await _repo.getVendor();
    result.fold(
      (failure) => emit(VendorError(failure.message)),   // État : erreur
      (vendor)  => emit(VendorLoaded(vendor)),           // État : succès
    );
  }
}
```

### Les états (sealed classes)

Chaque cubit définit ses états possibles avec une **sealed class** :

```dart
sealed class VendorState {}
class VendorInitial extends VendorState {}
class VendorLoading extends VendorState {}
class VendorLoaded  extends VendorState { final Vendor vendor; ... }
class VendorError   extends VendorState { final String message; ... }
```

`sealed` garantit qu'il n'existe **aucun autre état possible**. Le compilateur peut alors vérifier que tous les cas sont gérés dans un `switch`.

### Comment un widget écoute un Cubit

```dart
BlocBuilder<VendorCubit, VendorState>(
  builder: (context, state) {
    return switch (state) {
      VendorInitial()  => const SizedBox(),
      VendorLoading()  => const CircularProgressIndicator(),
      VendorLoaded(vendor: final v) => Text(v.shopName),
      VendorError(message: final m) => Text(m),
    };
  },
)
```

`BlocBuilder` se reconstruit automatiquement à chaque `emit()`.

### BlocListener vs BlocBuilder

- `BlocBuilder` → rebuild le widget (affichage).
- `BlocListener` → réagit à un état **une seule fois** (navigation, toast, dialog).

```dart
BlocListener<AccountCubit, AccountState>(
  listener: (context, state) {
    if (state is AccountError) {
      AppToast.show(context, state.message, isError: true); // Effet de bord
    }
  },
  child: ...,
)
```

---

## 5. Le cycle d'un appel API (exemple complet)

Prenons "charger le profil vendeur" de bout en bout.

### Étape 1 — L'UI déclenche l'action

```dart
// Dans app_shell.dart, au démarrage
getIt<VendorCubit>().load();
```

### Étape 2 — Le Cubit appelle le Repository (domaine)

```dart
// vendor_cubit.dart
Future<void> load() async {
  emit(const VendorLoading());
  final result = await _repo.getVendor(); // _repo est VendorRepository (abstrait)
  result.fold(
    (failure) => emit(VendorError(failure.message)),
    (vendor)  => emit(VendorLoaded(vendor)),
  );
}
```

### Étape 3 — Le Repository impl appelle le DataSource

```dart
// vendor_repository_impl.dart
Future<Either<Failure, Vendor>> getVendor() async {
  try {
    final model = await _remote.getVendor(); // Appel HTTP
    return Right(model.toDomain());          // Convertit en entité pure
  } on ApiException catch (e) {
    if (e.isNetworkError) return const Left(NetworkFailure());
    return Left(ServerFailure(e.firstMessage));
  }
}
```

### Étape 4 — Le DataSource fait l'appel HTTP

```dart
// vendor_remote_datasource.dart
Future<VendorModel> getVendor() async {
  final res = await _client.get('/vendors/me');
  return VendorModel.fromJson(res.data['data'] as Map<String, dynamic>);
}
```

### Étape 5 — Le Model parse le JSON

```dart
// vendor_model.dart
factory VendorModel.fromJson(Map<String, dynamic> json) {
  final user = json['user'] as Map<String, dynamic>;
  return VendorModel(
    id: json['id'] as String,
    firstName: user['firstName'] as String,
    shopName: json['shopName'] as String,
    // ...
  );
}

Vendor toDomain() => Vendor(id: id, firstName: firstName, shopName: shopName, ...);
```

### Résumé visuel

```
VendorCubit.load()
    → VendorRepository.getVendor()           [interface abstraite]
        → VendorRepositoryImpl.getVendor()   [implémentation concrète]
            → VendorRemoteDataSource.getVendor()
                → ApiClient.get('/vendors/me')
                    → Dio → HTTP GET → API
                ← Response JSON
            ← VendorModel (JSON parsé)
        ← Either<Failure, Vendor> (entité pure)
    ← Either<Failure, Vendor>
← emit(VendorLoaded(vendor)) → widget reconstruit
```

---

## 6. Either — Gérer les erreurs sans exceptions

Le projet utilise **fpdart** et son type `Either<L, R>` pour gérer les erreurs.

`Either` est une valeur qui est soit :
- `Left(failure)` → une erreur
- `Right(data)` → un succès

```dart
final result = await _repo.getVendor();

result.fold(
  (failure) => print('Erreur : ${failure.message}'),  // Left
  (vendor)  => print('Vendeur : ${vendor.shopName}'), // Right
);
```

**Pourquoi ne pas utiliser try/catch dans le Cubit ?**

Les exceptions sont invisibles — le compilateur ne peut pas te forcer à les gérer. `Either` rend l'erreur **explicite dans la signature** : `Future<Either<Failure, Vendor>>` dit clairement "cette méthode peut échouer". Le compilateur t'oblige à gérer les deux cas.

---

## 7. La navigation (GoRouter)

La navigation est gérée par **GoRouter**. Les routes sont déclarées dans `app_router.dart` et les chemins dans `routes.dart` :

```dart
abstract class Routes {
  static const home          = '/vendor/home';
  static const balance       = '/vendor/balance';
  static const notifications = '/vendor/notifications';
  // ...
}
```

GoRouter a un système de **guards** (redirections automatiques) :

```dart
String? _guard(BuildContext context, GoRouterState state) {
  if (authState is AuthUnauthenticated) {
    return Routes.login; // Redirige si non connecté
  }
  if (authState is AuthAuthenticated && isOnAuthScreen) {
    return Routes.home;  // Redirige si déjà connecté
  }
  return null; // Pas de redirection
}
```

À chaque changement d'état de `AuthBloc`, GoRouter ré-évalue le guard automatiquement.

---

## 8. Singletons globaux vs instances par écran

C'est une décision importante dans ce projet.

### Cubits globaux (singleton dans GetIt)

`VendorCubit`, `OrdersCubit`, `ItemsCubit`, `NotificationsCubit` sont des **singletons**.

- Ils sont créés une fois au démarrage.
- Fournis à toute l'app via `MultiBlocProvider` dans `AppShell`.
- Leur état **persiste** quand on navigue entre les onglets.
- Exemple : quand tu vas dans l'onglet Menu puis reviens à l'Accueil, les commandes sont déjà chargées.

### Cubits par écran (factory dans GetIt ou créés dans le router)

`LoginBloc`, `CashinCubit`, `BalanceCubit` sont des **factories** ou créés directement dans le router.

- Une nouvelle instance à chaque visite de l'écran.
- L'état repart de zéro quand on quitte et revient.
- Exemple : `BalanceCubit` est créé dans le router lors du push de `/vendor/balance`, et détruit quand on revient en arrière.

```dart
// app_router.dart — BalanceCubit créé à la volée, pas dans GetIt
GoRoute(
  path: Routes.balance,
  builder: (_, _) => MultiBlocProvider(
    providers: [
      BlocProvider.value(value: getIt<VendorCubit>()), // partagé
      BlocProvider(create: (_) => BalanceCubit(getIt<BalanceRepository>())), // nouveau
    ],
    child: const BalanceScreen(),
  ),
),
```

---

## 9. Le design system

Aucune valeur n'est hardcodée dans les widgets. Tout passe par les tokens :

| Token | Usage |
|---|---|
| `AppColors.gold` | Couleur principale (boutons, accents) |
| `AppColors.maroon` | Titres, éléments importants |
| `AppColors.mute` | Textes secondaires |
| `AppColors.ink` | Texte principal |
| `AppColors.paper` | Fond des écrans |
| `AppSpacing.md` | Espacement standard |
| `AppRadius.pill` | Bordures arrondies (boutons) |
| `AppShadows.md` | Ombres moyennes |
| `AppTextStyles.h2` | Titres de section |
| `AppTextStyles.body` | Corps de texte |

---

## 10. Variables d'environnement

Les secrets (URL de l'API, clés) ne sont **jamais** dans le code. Ils sont dans un fichier `.env` à la racine (ignoré par git) :

```
API_BASE_URL=https://api.grandfrere.com
```

Chargé au démarrage avec `flutter_dotenv` :

```dart
await dotenv.load(); // lit .env
// puis dans ApiClient :
baseUrl: dotenv.env['API_BASE_URL'] ?? ''
```
