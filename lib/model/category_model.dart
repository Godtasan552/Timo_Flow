class Category {
  final String id;
  final String name;
  final String? description;
  final String color; // Hex color code
  final String? icon; // Icon name or code
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.color = '#2196F3', // Default blue color
    this.icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Create Category from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String? ?? '#2196F3',
      icon: json['icon'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Convert Category to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a copy of the category with updated fields
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Predefined category colors
class CategoryColors {
  static const String blue = '#2196F3';
  static const String red = '#F44336';
  static const String green = '#4CAF50';
  static const String orange = '#FF9800';
  static const String purple = '#9C27B0';
  static const String teal = '#009688';
  static const String indigo = '#3F51B5';
  static const String pink = '#E91E63';
  static const String brown = '#795548';
  static const String grey = '#9E9E9E';

  static const List<String> all = [
    blue,
    red,
    green,
    orange,
    purple,
    teal,
    indigo,
    pink,
    brown,
    grey,
  ];
}

// Predefined category icons (using Material Icons names)
class CategoryIcons {
  static const String work = 'work';
  static const String personal = 'person';
  static const String education = 'school';
  static const String health = 'health_and_safety';
  static const String family = 'family_restroom';
  static const String friends = 'group';
  static const String home = 'home';
  static const String shopping = 'shopping_cart';
  static const String travel = 'flight';
  static const String sports = 'sports';
  static const String entertainment = 'movie';
  static const String finance = 'account_balance_wallet';
  static const String food = 'restaurant';
  static const String event = 'event';
  static const String meeting = 'meeting_room';
  static const String reminder = 'notifications';
  static const String birthday = 'cake';
  static const String hobby = 'palette';
  static const String fitness = 'fitness_center';
  static const String project = 'assignment';

  static const List<String> all = [
    work,
    personal,
    education,
    health,
    family,
    friends,
    home,
    shopping,
    travel,
    sports,
    entertainment,
    finance,
    food,
    event,
    meeting,
    reminder,
    birthday,
    hobby,
    fitness,
    project,
  ];
}

// Default categories with predefined settings
class DefaultCategories {
  static List<Category> get all => [
    Category(
      id: 'personal',
      name: 'งานส่วนตัว',
      description: 'งานและกิจกรรมส่วนตัว',
      color: CategoryColors.blue,
      icon: CategoryIcons.personal,
    ),
    Category(
      id: 'work',
      name: 'งานที่ทำ',
      description: 'งานในหน้าที่การงาน',
      color: CategoryColors.orange,
      icon: CategoryIcons.work,
    ),
    Category(
      id: 'education',
      name: 'การศึกษา',
      description: 'เรียน อ่านหนังสือ เรื่องการศึกษา',
      color: CategoryColors.green,
      icon: CategoryIcons.education,
    ),
    Category(
      id: 'health',
      name: 'สุขภาพ',
      description: 'ออกกำลังกาย ดูแลสุขภาพ',
      color: CategoryColors.red,
      icon: CategoryIcons.health,
    ),
    Category(
      id: 'family',
      name: 'ครอบครัว',
      description: 'กิจกรรมกับครอบครัว',
      color: CategoryColors.pink,
      icon: CategoryIcons.family,
    ),
    Category(
      id: 'friends',
      name: 'เพื่อน',
      description: 'กิจกรรมกับเพื่อน',
      color: CategoryColors.purple,
      icon: CategoryIcons.friends,
    ),
    Category(
      id: 'home',
      name: 'งานบ้าน',
      description: 'ทำความสะอาด จัดบ้าน',
      color: CategoryColors.brown,
      icon: CategoryIcons.home,
    ),
    Category(
      id: 'shopping',
      name: 'ช้อปปิ้ง',
      description: 'ซื้อของ จ่ายตลาด',
      color: CategoryColors.teal,
      icon: CategoryIcons.shopping,
    ),
  ];
}
