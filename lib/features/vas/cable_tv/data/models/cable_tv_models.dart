class CableTvSmartcard {
  final String id;
  final String smartcardNumber;
  final String provider;
  final String customerName;
  final String packageName;

  const CableTvSmartcard({
    required this.id,
    required this.smartcardNumber,
    required this.provider,
    required this.customerName,
    required this.packageName,
  });
}

class CableTvCustomer {
  final String name;
  final String currentPackage;
  final String status;
  final String dueDate;

  const CableTvCustomer({
    required this.name,
    required this.currentPackage,
    required this.status,
    required this.dueDate,
  });
}

class CableTvPackage {
  final String title;
  final String description;
  final int amountKobo;
  final String priceLabel;

  const CableTvPackage({
    required this.title,
    required this.description,
    required this.amountKobo,
    required this.priceLabel,
  });
}

const Map<String, List<CableTvPackage>> kCableTvPackages = {
  'DStv': [
    CableTvPackage(title: 'Padi', description: 'Local channels', amountKobo: 250000, priceLabel: '₦2,500'),
    CableTvPackage(title: 'Yanga', description: 'Local + Entertainment', amountKobo: 295000, priceLabel: '₦2,950'),
    CableTvPackage(title: 'Confam', description: 'Extended channels', amountKobo: 620000, priceLabel: '₦6,200'),
    CableTvPackage(title: 'Compact', description: 'Popular bundle', amountKobo: 1140000, priceLabel: '₦11,400'),
    CableTvPackage(title: 'Compact+', description: 'Sports + Entertainment', amountKobo: 1660000, priceLabel: '₦16,600'),
    CableTvPackage(title: 'Premium', description: 'Full bouquet', amountKobo: 2950000, priceLabel: '₦29,500'),
  ],
  'GOtv': [
    CableTvPackage(title: 'Smallie', description: 'Basic channels', amountKobo: 110000, priceLabel: '₦1,100'),
    CableTvPackage(title: 'Jinja', description: 'More entertainment', amountKobo: 164000, priceLabel: '₦1,640'),
    CableTvPackage(title: 'Jolli', description: 'Family viewing', amountKobo: 246000, priceLabel: '₦2,460'),
    CableTvPackage(title: 'Max', description: 'Sports + Movies', amountKobo: 415000, priceLabel: '₦4,150'),
    CableTvPackage(title: 'Supa', description: 'Full bouquet', amountKobo: 550000, priceLabel: '₦5,500'),
  ],
  'Startimes': [
    CableTvPackage(title: 'Nova', description: 'Local channels', amountKobo: 120000, priceLabel: '₦1,200'),
    CableTvPackage(title: 'Basic', description: 'Basic entertainment', amountKobo: 210000, priceLabel: '₦2,100'),
    CableTvPackage(title: 'Smart', description: 'Standard package', amountKobo: 280000, priceLabel: '₦2,800'),
    CableTvPackage(title: 'Chinese', description: 'Chinese channels', amountKobo: 350000, priceLabel: '₦3,500'),
    CableTvPackage(title: 'Super', description: 'Premium content', amountKobo: 420000, priceLabel: '₦4,200'),
  ],
};
