class SupportContact {
  const SupportContact._();

  static const phone = '+2250103788294';
  static const displayPhone = '+225 01 03 78 82 94';

  static final callUri = Uri.parse('tel:$phone');
  static final whatsAppUri = Uri.parse('https://wa.me/${phone.substring(1)}');
}
