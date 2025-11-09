import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/book.dart';
import '../constants/app_colors.dart';
import '../screens/reader/reader_screen.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  Widget _buildCoverImage() {
    if (book.coverUrl == null) {
      return const Center(
        child: Icon(
          Icons.book,
          size: 48,
          color: AppColors.goldenAccent,
        ),
      );
    }

    // Перевірка чи це SVG файл
    if (book.coverUrl!.endsWith('.svg')) {
      return SvgPicture.asset(
        book.coverUrl!,
        fit: BoxFit.cover,
        placeholderBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Image.asset(
        book.coverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.book,
              size: 48,
              color: AppColors.goldenAccent,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Обкладинка
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: AppColors.lightGold,
                child: _buildCoverImage(),
              ),
            ),
            
            // Інформація про книгу
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Назва
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    
                    // Автор
                    Text(
                      book.author,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.softBrown,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    
                    // Рейтинг та кнопка "Читати"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Рейтинг
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.goldenAccent,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                book.averageRating.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        
                        // Кнопка "Читати"
                        Material(
                          color: AppColors.goldenAccent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReaderScreen(book: book),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.menu_book,
                                    size: 14,
                                    color: AppColors.darkBrownText,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Читати',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.darkBrownText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
