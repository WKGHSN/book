import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/user.dart';
import '../../models/book.dart';
import '../../services/hive_service.dart';
import '../../services/background_service.dart';
import '../auth/login_screen.dart';
import '../../constants/app_colors.dart';
import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _currentUser = HiveService.getCurrentUser();
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Вихід'),
        content: const Text('Ви впевнені, що хочете вийти з акаунту?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Вийти'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await HiveService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  void _showAddBookDialog() {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedGenre = 'Романтика';
    final genres = [
      'Романтика',
      'Фантастика',
      'Детективи',
      'Психологія',
      'Пригоди',
      'Класика',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Додати власну книгу'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Назва книги'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Автор'),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  initialValue: selectedGenre,
                  decoration: const InputDecoration(labelText: 'Жанр'),
                  items: genres
                      .map((genre) => DropdownMenuItem(
                            value: genre,
                            child: Text(genre),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedGenre = value!);
                  },
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Опис'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'txt'],
                  );
                  if (result != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Файл вибрано: ${result.files.first.name}'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Вибрати файл'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  authorController.text.isNotEmpty) {
                final newBook = Book(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  author: authorController.text,
                  genre: selectedGenre,
                  description: descriptionController.text.isNotEmpty
                      ? descriptionController.text
                      : 'Опис відсутній',
                );
                await HiveService.addBook(newBook);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Книгу успішно додано!')),
                  );
                }
              }
            },
            child: const Text('Додати'),
          ),
        ],
      ),
    );
  }

  void _showBackgroundSelector() {
    final backgroundProvider = Provider.of<BackgroundProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Виберіть фон',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: BackgroundService.backgrounds.length,
                itemBuilder: (context, index) {
                  final bg = BackgroundService.backgrounds[index];
                  final isSelected = backgroundProvider.currentBackgroundId == bg.id;
                  
                  return GestureDetector(
                    onTap: () {
                      backgroundProvider.setBackground(bg.id);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        gradient: bg.gradient,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.goldenAccent 
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.goldenAccent,
                              size: 32,
                            ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              bg.name,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final themeProvider = Provider.of<ThemeProvider>(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          flexibleSpace: FlexibleSpaceBar(
            background: Consumer<BackgroundProvider>(
              builder: (context, bgProvider, _) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: bgProvider.currentBackground.gradient,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.white,
                        child: Text(
                          _currentUser!.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBrownText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _currentUser!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.darkBrownText,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _currentUser!.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.softBrown,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Статистика
                Card(
                  color: Theme.of(context).cardColor.withValues(alpha: 0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Улюблених',
                              _currentUser!.favoriteBooks.length.toString(),
                              Icons.favorite,
                            ),
                            _buildStatItem(
                              'Прочитано',
                              _currentUser!.booksRead.toString(),
                              Icons.book,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Налаштування
                Text(
                  'Налаштування',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Card(
                  color: Theme.of(context).cardColor.withValues(alpha: 0.9),
                  child: Column(
                    children: [
                      // Перемикач теми (перенесений з головної)
                      SwitchListTile(
                        title: Text(
                          'Темна тема',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          'Комфортне читання вночі',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.setTheme(value);
                        },
                        secondary: Icon(
                          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                      const Divider(height: 1),
                      // Вибір фону
                      ListTile(
                        leading: Icon(
                          Icons.palette,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        title: Text(
                          'Фон застосунку',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Consumer<BackgroundProvider>(
                          builder: (context, bgProvider, _) {
                            return Text(
                              bgProvider.currentBackground.name,
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          },
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: _showBackgroundSelector,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Дії
                Text(
                  'Дії',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Card(
                  color: Theme.of(context).cardColor.withValues(alpha: 0.9),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        title: Text(
                          'Додати власну книгу',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: _showAddBookDialog,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: AppColors.error,
                        ),
                        title: const Text(
                          'Вийти з акаунту',
                          style: TextStyle(color: AppColors.error),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.error,
                        ),
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: AppColors.goldenAccent,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
