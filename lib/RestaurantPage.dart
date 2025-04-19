import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class MenuItem {
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final Map<String, dynamic> nutritionInfo;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.nutritionInfo,
  });
}

class CartItem {
  final MenuItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});
}

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({Key? key}) : super(key: key);

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  final List<MenuItem> menuItems = [
    MenuItem(
      name: 'Cheeseburger',
      description: 'Beef burger on crisp baby gem lettuce, heritage tomato, onion and our own burger sauce, topped with your choice of smoked Applewood cheese, cheddar or American slice.',
      price: 11.95,
      image: 'assets/images/burger.jpg',
      category: 'Burger',
      nutritionInfo: {
        'kcal': 343,
        'carbs': 32,
        'protein': 17,
        'fat': 16.4,
      },
    ),
    MenuItem(
      name: 'Mushroom Udon',
      description: 'Fresh udon noodles with shiitake mushrooms, bok choy, and savory broth.',
      price: 14.50,
      image: 'assets/images/udon.jpg',
      category: 'Noodles',
      nutritionInfo: {
        'kcal': 310,
        'carbs': 48,
        'protein': 12,
        'fat': 9.2,
      },
    ),
    MenuItem(
      name: 'Spicy Beef Noodle',
      description: 'Tender beef slices with rice noodles in spicy broth with vegetables.',
      price: 15.75,
      image: 'assets/images/beef_noodle.jpg',
      category: 'Noodles',
      nutritionInfo: {
        'kcal': 425,
        'carbs': 52,
        'protein': 28,
        'fat': 14.5,
      },
    ),
    MenuItem(
      name: 'Kuro Kosho Jiru',
      description: 'Perfectly warming and energizing pumpkin soup for those who lead a vegetarian lifestyle. With ramen, pumpkin, onion, garlic, greens, nori, ginger, olive oil, vegetable broth, tomatoes, chili, coconut milk, soy sauce, turmeric, cumin, salt, pepper, pumpkin seeds.',
      price: 5.00,
      image: 'assets/images/pumpkin_soup.jpg',
      category: 'Soup',
      nutritionInfo: {
        'kcal': 359,
        'carbs': 42,
        'protein': 8,
        'fat': 18.3,
      },
    ),
    MenuItem(
      name: 'Pancakes',
      description: 'Fluffy pancakes served with maple syrup and fresh berries.',
      price: 9.25,
      image: 'assets/images/pancakes.jpg',
      category: 'Dessert',
      nutritionInfo: {
        'kcal': 420,
        'carbs': 68,
        'protein': 9,
        'fat': 15.0,
      },
    ),
  ];

  String selectedCategory = 'All';
  List<CartItem> cart = [];

  List<String> categories = ['All', 'Burger', 'Pizza', 'Noodles', 'Soup', 'Dessert', 'Vegan'];

  List<MenuItem> get filteredItems {
    if (selectedCategory == 'All') {
      return menuItems;
    } else {
      return menuItems.where((item) => item.category == selectedCategory).toList();
    }
  }

  double get totalAmount {
    return cart.fold(0, (sum, item) => sum + (item.item.price * item.quantity));
  }

  void addToCart(MenuItem item) {
    setState(() {
      final existingIndex = cart.indexWhere((cartItem) => cartItem.item.name == item.name);
      if (existingIndex >= 0) {
        cart[existingIndex].quantity++;
      } else {
        cart.add(CartItem(item: item));
      }
    });
  }

  void removeFromCart(int index) {
    setState(() {
      if (cart[index].quantity > 1) {
        cart[index].quantity--;
      } else {
        cart.removeAt(index);
      }
    });
  }

  void showOrderConfirmation() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add items to your order first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Your order has been placed! Total: \$${totalAmount.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        elevation: 6,
      ),

    );

    setState(() {
      cart.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top navigation
         // i removed it if u want it tell me
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios_rounded, color: Colors.blueGrey[600], ),
                    SizedBox(width:5 ),
                    Text('Back', style: GoogleFonts.nunito(color: Colors.blueGrey[600], fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Hello!\nWhat do you want today?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Categories
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = categories[index];
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedCategory == categories[index]
                                  ? Colors.indigo.shade200
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _getCategoryIcon(categories[index]),
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            categories[index],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: (filteredItems.length / 2).ceil(),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      for (int i = 0; i < 2; i++)
                        if (index * 2 + i < filteredItems.length)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: i == 0 ? 8.0 : 0.0,
                                left: i == 1 ? 8.0 : 0.0,
                                bottom: 16.0,
                              ),
                              child: _buildMenuItemCard(filteredItems[index * 2 + i]),
                            ),
                          ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            if (cart.isNotEmpty)
              Text(
                '${cart.fold(0, (sum, item) => sum + item.quantity)} items',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (cart.isNotEmpty) const SizedBox(width: 4),
            if (cart.isNotEmpty)
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            const Spacer(),
            cart.isNotEmpty
                ? Row(
              children: [
                TextButton(
                  onPressed: () {
                    _showCartModal(context);
                  },
                  child: Text(
                    'View Cart',
                    style: TextStyle(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: showOrderConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Order Now'),
                ),
              ],
            )
                : ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('No Items Yet'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCartModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Order',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: cart.isEmpty
                        ? const Center(
                      child: Text('Your cart is empty'),
                    )
                        : ListView.separated(
                      itemCount: cart.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = cart[index];
                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                item.item.image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${item.item.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      if (item.quantity > 1) {
                                        item.quantity--;
                                      } else {
                                        cart.removeAt(index);
                                      }
                                      this.setState(() {});
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      item.quantity++;
                                      this.setState(() {});
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const Divider(thickness: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showOrderConfirmation();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Confirm Order'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'All':
        return Icons.restaurant;
      case 'Burger':
        return Icons.lunch_dining;
      case 'Pizza':
        return Icons.local_pizza;
      case 'Noodles':
        return Icons.ramen_dining;
      case 'Soup':
        return Icons.soup_kitchen;
      case 'Dessert':
        return Icons.cake;
      case 'Vegan':
        return Icons.spa;
      default:
        return Icons.restaurant_menu;
    }
  }

  Widget _buildMenuItemCard(MenuItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuItemDetailPage(
              item: item,
              onAddToCart: addToCart,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.asset(
                item.image,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, size: 40),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '★ 4.5',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItemDetailPage extends StatefulWidget {
  final MenuItem item;
  final Function(MenuItem) onAddToCart;

  const MenuItemDetailPage({
    Key? key,
    required this.item,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  State<MenuItemDetailPage> createState() => _MenuItemDetailPageState();
}

class _MenuItemDetailPageState extends State<MenuItemDetailPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Image.asset(
                          widget.item.image,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250,
                              width: double.infinity,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported, size: 80),
                            );
                          },
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 16,
                          child: IconButton(
                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${widget.item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.brown.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 16),
                          // Nutrition info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildNutritionInfo(
                                  '${widget.item.nutritionInfo['kcal']}',
                                  'kcal'
                              ),
                              _buildNutritionInfo(
                                  '${widget.item.nutritionInfo['carbs']}',
                                  'Carbs'
                              ),
                              _buildNutritionInfo(
                                  '${widget.item.nutritionInfo['protein']}',
                                  'Protein'
                              ),
                              _buildNutritionInfo(
                                  '${widget.item.nutritionInfo['fat']}',
                                  'Fat'
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.item.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),
                          // Reviews section
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey.shade300,
                                child: const Text('S'),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rahma Z.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      for (int i = 0; i < 5; i++)
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'So delicious burger! Really recommend!',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              for (int i = 0; i < 3; i++)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Icon(Icons.thumb_up, color: Colors.red.shade300, size: 16),
                                ),
                            ],
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom action bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        for (int i = 0; i < quantity; i++) {
                          widget.onAddToCart(widget.item);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.item.name} added to your order'),
                            backgroundColor: Colors.brown.shade400,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: EdgeInsets.all(6),
                            elevation: 6, // Optional: adds a shadow
                          ),

                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Add to order'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}