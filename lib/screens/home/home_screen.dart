import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../models/user.dart';
import '../../services/hive_service.dart';
import '../book/book_detail_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/book_card.dart';
import '../../widgets/genre_section.dart';
import '../../main.dart';
import '../../constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];
  User? _currentUser;
  String? _selectedGenre; // null означає "Всі"

  final List<String> _genres = [
    'Всі',
    'Романтика',
    'Фантастика',
    'Детективи',
    'Психологія',
    'Пригоди',
    'Класика',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _currentUser = HiveService.getCurrentUser();
      _allBooks = HiveService.getAllBooks();
      _filteredBooks = _allBooks;
    });
  }

  void _filterBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = _selectedGenre == null || _selectedGenre == 'Всі'
            ? _allBooks
            : _allBooks.where((book) => book.genre == _selectedGenre).toList();
      } else {
        var filtered = _allBooks.where((book) {
          return book.title.toLowerCase().contains(query.toLowerCase()) ||
              book.author.toLowerCase().contains(query.toLowerCase());
        });
        
        if (_selectedGenre != null && _selectedGenre != 'Всі') {
          filtered = filtered.where((book) => book.genre == _selectedGenre);
        }
        
        _filteredBooks = filtered.toList();
      }
    });
  }

  void _selectGenre(String genre) {
    setState(() {
      _selectedGenre = genre;
      _filterBooks(_searchController.text);
    });
  }

  List<Book> _getBooksByGenre(String genre) {
    return _allBooks.where((book) => book.genre == genre).take(3).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildLibraryScreen() {
    final backgroundProvider = Provider.of<BackgroundProvider>(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: backgroundProvider.currentBackground.gradient,
      ),
      child: CustomScrollView(
        slivers: [
          // Компактний AppBar з кнопкою зміни теми
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'BookWave',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              // Кнопка зміни теми (сонце/місяць)
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode 
                          ? Icons.light_mode 
                          : Icons.dark_mode,
                      color: themeProvider.isDarkMode
                          ? AppColors.goldenAccent
                          : AppColors.darkBrownText,
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                    tooltip: themeProvider.isDarkMode 
                        ? 'Світла тема' 
                        : 'Темна тема',
                  );
                },
              ),
            ],
          ),

          // Компактний фільтр категорій (чіпси)
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _genres.length,
                itemBuilder: (context, index) {
                  final genre = _genres[index];
                  final isSelected = _selectedGenre == genre || 
                      (_selectedGenre == null && genre == 'Всі');
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(genre),
                      selected: isSelected,
                      onSelected: (selected) {
                        _selectGenre(genre);
                      },
                      backgroundColor: Colors.white.withValues(alpha: 0.8),
                      selectedColor: AppColors.goldenAccent,
                      checkmarkColor: AppColors.darkBrownText,
                      labelStyle: TextStyle(
                        color: isSelected 
                            ? AppColors.darkBrownText 
                            : AppColors.softBrown,
                        fontWeight: isSelected 
                            ? FontWeight.bold 
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Пошук (знижений)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: _filterBooks,
                decoration: InputDecoration(
                  hintText: 'Пошук книг або авторів...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterBooks('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),

          // Результати пошуку або жанрові категорії (карусель)
          if (_searchController.text.isNotEmpty || _selectedGenre != null && _selectedGenre != 'Всі')
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: _filteredBooks.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Книг не знайдено',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return BookCard(
                            book: _filteredBooks[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookDetailScreen(
                                    book: _filteredBooks[index],
                                  ),
                                ),
                              ).then((_) => _loadData());
                            },
                          );
                        },
                        childCount: _filteredBooks.length,
                      ),
                    ),
            )
          else
            // Жанрові секції (горизонтальна карусель)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final genre = _genres[index + 1]; // Пропускаємо "Всі"
                  final books = _getBooksByGenre(genre);
                  if (books.isEmpty) return const SizedBox.shrink();
                  
                  return GenreSection(
                    genre: genre,
                    books: books,
                    onBookTap: (book) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailScreen(book: book),
                        ),
                      ).then((_) => _loadData());
                    },
                  );
                },
                childCount: _genres.length - 1, // Без "Всі"
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundProvider = Provider.of<BackgroundProvider>(context);
    
    final screens = [
      _buildLibraryScreen(),
      Container(
        decoration: BoxDecoration(
          gradient: backgroundProvider.currentBackground.gradient,
        ),
        child: const FavoritesScreen(),
      ),
      Container(
        decoration: BoxDecoration(
          gradient: backgroundProvider.currentBackground.gradient,
        ),
        child: const ProfileScreen(),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index != 0) {
            _searchController.clear();
            _filterBooks('');
          } else {
            _loadData(); // Оновлюємо дані при поверненні на головну
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Головна',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Улюблені',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профіль',
          ),
        ],
      ),
    );
  }
}
