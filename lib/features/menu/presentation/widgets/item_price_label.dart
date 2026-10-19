import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/vendor_item.dart';

/// Displayed price: "500 FCFA" or "Dès 50 FCFA · pas de 25 F".
String itemPriceLabel(VendorItem item) => item.isVariablePrice
    ? 'Dès ${formatXof(item.price)} FCFA · pas de ${formatXof(item.step)} F'
    : '${formatXof(item.price)} FCFA';
