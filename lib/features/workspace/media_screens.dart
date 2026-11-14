import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'crm_store.dart';
import 'crm_ui.dart';
import 'crm_services.dart';

/// Legacy reference photo class for backward compatibility.
class ReferencePhoto {
  const ReferencePhoto(this.asset, this.category, this.caption);
  final String asset, category, caption;
}

const referencePhotos = [
  ReferencePhoto('assets/images/office.png', 'General', 'Acme Corp Visit'),
  ReferencePhoto('assets/images/meeting.png', 'General', 'Team Meeting'),
  ReferencePhoto('assets/images/handshake.png', 'Product', 'Customer Meeting'),
  ReferencePhoto(
    'assets/images/visiting_card.png',
    'Visiting Card',
    'Alex Morgan',
  ),
  ReferencePhoto(
    'assets/images/storefront_camera.png',
    'Store Front',
    'Veridian Store',
  ),
];

/// Page 75: Photos Gallery Screen with selection mode, categories, and count.
class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});
  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  String selectedCategory = 'All';
  bool isSelectionMode = false;
  final Set<String> selectedPhotoIds = {};

  final categories = const [
    'All',
    'Storefront',
    'Visiting Card',
    'Document',
    'Site Inspection',
    'General',
  ];

  void _toggleSelection(String id) {
    setState(() {
      if (selectedPhotoIds.contains(id)) {
        selectedPhotoIds.remove(id);
        if (selectedPhotoIds.isEmpty) isSelectionMode = false;
      } else {
        selectedPhotoIds.add(id);
      }
    });
  }

  void _confirmDeleteSelected(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DeletePhotosModal(
        count: selectedPhotoIds.length,
        onConfirm: () async {
          final store = CrmStore.instance;
          try {
            await store.deletePhotos(selectedPhotoIds);
            setState(() {
              selectedPhotoIds.clear();
              isSelectionMode = false;
            });
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Selected photos removed')),
            );
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete photos: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CrmStore.instance,
      builder: (context, _) {
        final store = CrmStore.instance;
        final allPhotos = store.photos;
        final filteredPhotos = selectedCategory == 'All'
            ? allPhotos
            : allPhotos
                  .where(
                    (p) =>
                        p.category.toLowerCase() ==
                        selectedCategory.toLowerCase(),
                  )
                  .toList();

        return Scaffold(
          appBar: AppBar(
            title: isSelectionMode
                ? Text(
                    '${selectedPhotoIds.length} Selected',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Photos',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${allPhotos.length}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
            leading: isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      isSelectionMode = false;
                      selectedPhotoIds.clear();
                    }),
                  )
                : null,
            actions: [
              if (isSelectionMode) ...[
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Share',
                  onPressed: () {
                    DeviceService.shareContent(
                      title: 'Photos',
                      text:
                          'Sharing ${selectedPhotoIds.length} CRM field photos',
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download_outlined),
                  tooltip: 'Download',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Downloaded ${selectedPhotoIds.length} photos to device storage',
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  tooltip: 'Delete',
                  onPressed: () => _confirmDeleteSelected(context),
                ),
              ] else ...[
                TextButton(
                  onPressed: () => setState(() => isSelectionMode = true),
                  child: const Text(
                    'Select',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.photo_camera_outlined),
                  tooltip: 'Capture Photo',
                  onPressed: () => open(context, '/camera'),
                ),
              ],
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Category filter chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textDark,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      showCheckmark: false,
                      onSelected: (_) => setState(() => selectedCategory = cat),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredPhotos.length} photos · Sorted by newest',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  InkWell(
                    onTap: () => open(context, '/voice-notes'),
                    child: const Row(
                      children: [
                        Icon(Icons.mic, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Voice Notes',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (filteredPhotos.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 54,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No photos in this category',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the camera button to take a photo',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredPhotos.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) {
                    final photo = filteredPhotos[index];
                    final isSelected = selectedPhotoIds.contains(photo.id);

                    return InkWell(
                      onTap: () {
                        if (isSelectionMode) {
                          _toggleSelection(photo.id);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PhotoPreviewScreen(photo: photo),
                            ),
                          );
                        }
                      },
                      onLongPress: () {
                        if (!isSelectionMode) {
                          setState(() {
                            isSelectionMode = true;
                            selectedPhotoIds.add(photo.id);
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(11),
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.asset(
                                          photo.assetPath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons.image,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                        ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.65,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              photo.category,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (photo.hasOcr)
                                          Positioned(
                                            bottom: 6,
                                            left: 6,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.success
                                                    .withOpacity(0.9),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.check,
                                                    size: 10,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    'OCR',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        photo.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        photo.company,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelectionMode)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white.withOpacity(0.9),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Page 76: Photo Preview Screen with full image, metadata table, and OCR extraction.
class PhotoPreviewScreen extends StatefulWidget {
  const PhotoPreviewScreen({super.key, required this.photo});
  final PhotoRecord photo;

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  late PhotoRecord photo;
  bool isRetryingOcr = false;

  @override
  void initState() {
    super.initState();
    photo = widget.photo;
  }

  void _triggerRetryOcr() async {
    setState(() => isRetryingOcr = true);
    await Future.delayed(const Duration(milliseconds: 900));
    final extracted = await OcrService.extractTextFromImage(photo.assetPath);
    setState(() {
      photo.ocrText = extracted;
      photo.hasOcr = true;
      isRetryingOcr = false;
    });
    CrmStore.instance.update(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OCR text re-extracted successfully')),
    );
  }

  void _confirmDelete() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DeleteSinglePhotoModal(
        photo: photo,
        onConfirm: () async {
          final store = CrmStore.instance;
          try {
            await store.deletePhoto(photo.id);
            if (ctx.mounted) Navigator.pop(ctx);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Photo deleted')));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete photo: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          photo.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () {
              DeviceService.shareContent(
                title: photo.title,
                text:
                    '${photo.title} (${photo.company})\n\nOCR Text:\n${photo.ocrText}',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Delete',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Photo Container
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.05)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    photo.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.image, size: 64, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        photo.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (photo.hasOcr)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Text Extracted ✓',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Metadata Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Metadata & Properties',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),
                _metadataRow(Icons.business, 'Linked Client', photo.company),
                const Divider(height: 16),
                _metadataRow(
                  Icons.calendar_today_outlined,
                  'Date & Time',
                  '${photo.timestamp.day}/${photo.timestamp.month}/${photo.timestamp.year} · ${photo.timestamp.hour.toString().padLeft(2, "0")}:${photo.timestamp.minute.toString().padLeft(2, "0")}',
                ),
                const Divider(height: 16),
                _metadataRow(
                  Icons.sd_card_outlined,
                  'File Size',
                  photo.fileSize,
                ),
                const Divider(height: 16),
                _metadataRow(
                  Icons.aspect_ratio_outlined,
                  'Resolution',
                  photo.resolution,
                ),
                const Divider(height: 16),
                _metadataRow(
                  Icons.location_on_outlined,
                  'GPS Location',
                  photo.location,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // OCR Extracted Text Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.document_scanner_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Extracted OCR Text',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Copy Text',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: photo.ocrText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('OCR text copied to clipboard'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: SelectableText(
                    photo.ocrText.isNotEmpty
                        ? photo.ocrText
                        : 'No readable text detected.',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isRetryingOcr ? null : _triggerRetryOcr,
                    icon: isRetryingOcr
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 16),
                    label: Text(
                      isRetryingOcr
                          ? 'Scanning image...'
                          : 'Re-extract OCR Text',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metadataRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Delete single photo confirmation sheet
class _DeleteSinglePhotoModal extends StatelessWidget {
  const _DeleteSinglePhotoModal({required this.photo, required this.onConfirm});
  final PhotoRecord photo;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Icon(Icons.delete_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          const Text(
            'Delete This Photo?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'This photo and its extracted OCR text will be permanently removed from this account record.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Delete multiple selected photos confirmation sheet
class _DeletePhotosModal extends StatelessWidget {
  const _DeletePhotosModal({required this.count, required this.onConfirm});
  final int count;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Icon(
            Icons.delete_sweep_outlined,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Delete $count Photos?',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'The selected $count photos and all associated OCR data will be permanently deleted.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Delete All'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Page 77: Voice Notes Library Screen with transcription tags & duration.
class VoiceNotesLibraryScreen extends StatefulWidget {
  const VoiceNotesLibraryScreen({super.key});
  @override
  State<VoiceNotesLibraryScreen> createState() =>
      _VoiceNotesLibraryScreenState();
}

class _VoiceNotesLibraryScreenState extends State<VoiceNotesLibraryScreen> {
  String selectedCategory = 'All';
  final categories = const [
    'All',
    'Meeting Notes',
    'Debrief',
    'Legal',
    'Technical',
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CrmStore.instance,
      builder: (context, _) {
        final store = CrmStore.instance;
        final notes = selectedCategory == 'All'
            ? store.voiceNotes
            : store.voiceNotes
                  .where(
                    (v) =>
                        v.category.toLowerCase() ==
                        selectedCategory.toLowerCase(),
                  )
                  .toList();

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Voice Notes',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${store.voiceNotes.length}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.photo_library_outlined),
                tooltip: 'Photo Gallery',
                onPressed: () => open(context, '/photos'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Category chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textDark,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      showCheckmark: false,
                      onSelected: (_) => setState(() => selectedCategory = cat),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              if (notes.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.mic_off_outlined,
                          size: 54,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No voice notes recorded yet',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Record client requirements or meeting takeaways directly from visits',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecordingPlayerScreen(record: note),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${note.company} · ${note.category}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        note.duration,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      _transcriptionBadge(
                                        note.transcriptionStatus,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              final sampleVisit = store.visits.first;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VoiceNoteScreen(visit: sampleVisit),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.mic),
            label: const Text('Record Voice Note'),
          ),
        );
      },
    );
  }

  Widget _transcriptionBadge(String status) {
    Color bg;
    Color fg;
    String label = status;

    if (status.toLowerCase().contains('process')) {
      bg = Colors.amber.shade100;
      fg = Colors.amber.shade900;
    } else if (status.toLowerCase().contains('fail')) {
      bg = Colors.red.shade100;
      fg = Colors.red.shade900;
    } else {
      bg = Colors.green.shade100;
      fg = Colors.green.shade900;
      label = 'Transcribed ✓';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Page 77: Recording Player Screen with waveform, speed chips, and full transcript.
class RecordingPlayerScreen extends StatefulWidget {
  const RecordingPlayerScreen({super.key, required this.record});
  final VoiceNoteRecord record;

  @override
  State<RecordingPlayerScreen> createState() => _RecordingPlayerScreenState();
}

class _RecordingPlayerScreenState extends State<RecordingPlayerScreen> {
  bool isPlaying = false;
  double currentProgress = 0.45; // 45% through
  String selectedSpeed = '1x';
  final speeds = const ['1x', '1.5x', '2x'];

  void _confirmDelete() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DeleteRecordingModal(
        record: widget.record,
        onConfirm: () async {
          final store = CrmStore.instance;
          try {
            await store.deleteVoiceNote(widget.record.id);
            if (ctx.mounted) Navigator.pop(ctx);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Recording deleted')));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete voice note: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rec = widget.record;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Voice Note',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Transcript',
            onPressed: () {
              DeviceService.shareContent(
                title: rec.title,
                text:
                    '${rec.title} (${rec.company})\n\nTranscript:\n${rec.transcriptText}',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Delete',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Audio Player Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${rec.company} · ${rec.category}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 20),

                // Visual Waveform Container
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomPaint(
                    painter: _WaveformPainter(progress: currentProgress),
                    child: Container(),
                  ),
                ),
                const SizedBox(height: 12),

                // Progress numbers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1:15',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      rec.duration,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Player Controls (rewind 10, play/pause, forward 10, speed chips)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10_rounded, size: 28),
                      onPressed: () {
                        setState(() {
                          currentProgress = math.max(
                            0.0,
                            currentProgress - 0.1,
                          );
                        });
                      },
                    ),
                    const SizedBox(width: 14),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.all(16),
                      ),
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 32,
                        color: Colors.white,
                      ),
                      onPressed: () => setState(() => isPlaying = !isPlaying),
                    ),
                    const SizedBox(width: 14),
                    IconButton(
                      icon: const Icon(Icons.forward_10_rounded, size: 28),
                      onPressed: () {
                        setState(() {
                          currentProgress = math.min(
                            1.0,
                            currentProgress + 0.1,
                          );
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Speed chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: speeds.map((sp) {
                    final isSel = selectedSpeed == sp;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(sp, style: const TextStyle(fontSize: 11)),
                        selected: isSel,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                        showCheckmark: false,
                        onSelected: (_) => setState(() => selectedSpeed = sp),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Transcript Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.text_snippet_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'AI Audio Transcript',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Copy Transcript',
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: rec.transcriptText),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transcript copied to clipboard'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: SelectableText(
                    rec.transcriptText,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          DeviceService.shareContent(
                            title: rec.title,
                            text: rec.transcriptText,
                          );
                        },
                        icon: const Icon(Icons.share_outlined, size: 16),
                        label: const Text('Share Transcript'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Delete voice recording modal sheet with confirmation checkbox
class _DeleteRecordingModal extends StatefulWidget {
  const _DeleteRecordingModal({required this.record, required this.onConfirm});
  final VoiceNoteRecord record;
  final VoidCallback onConfirm;

  @override
  State<_DeleteRecordingModal> createState() => _DeleteRecordingModalState();
}

class _DeleteRecordingModalState extends State<_DeleteRecordingModal> {
  bool understood = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Icon(Icons.mic_off, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          const Text(
            'Delete Voice Recording?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'The audio file "${widget.record.title}" and its generated transcript will be permanently deleted.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: understood,
            onChanged: (v) => setState(() => understood = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'I understand this recording cannot be recovered',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: understood ? widget.onConfirm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Delete Recording'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Page 75: Empty Media Library Screen
class EmptyMediaLibraryScreen extends StatelessWidget {
  const EmptyMediaLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Media Library',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Captures Yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Photos, visiting cards, and voice memos taken during client visits will be neatly organized here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => open(context, '/visits'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.navigation_outlined, size: 18),
                  label: const Text("View Today's Visits"),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => open(context, '/help'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: const Text('Learn about Capture Tools'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page 75: Interactive Camera Preview Screen that adds photo to CrmStore
class CameraPreviewScreen extends StatefulWidget {
  const CameraPreviewScreen({super.key});
  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  String category = 'Storefront';
  bool flash = true;
  bool frontCamera = false;

  void _capturePhoto() async {
    final store = CrmStore.instance;
    final newPhoto = PhotoRecord(
      category: category,
      title: '$category Photo Capture',
      company: store.activeVisit?.company ?? 'Acme Corp',
      assetPath: category == 'Visiting Card'
          ? 'assets/images/visiting_card.png'
          : category == 'Storefront'
          ? 'assets/images/storefront_camera.png'
          : 'assets/images/office.png',
      fileSizeMb: 2.1,
      resolution: '4032 x 3024',
      location: '18.9986° N, 72.8258° E (Lower Parel)',
      ocrText: category == 'Visiting Card'
          ? 'ARJUN SHARMA\nVP OF PROCUREMENT\nPHONE: +91 98222 33445'
          : 'FIELD PULSE CAPTURE · STORE ENTRANCE VERIFIED',
    );

    try {
      await store.addPhoto(newPhoto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$category photo captured & added to gallery!'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PhotoPreviewScreen(photo: newPhoto),
                  ),
                );
              },
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => flash = !flash),
                icon: Icon(
                  flash ? Icons.flash_auto : Icons.flash_off,
                  color: Colors.white,
                  size: 17,
                ),
                label: Text(
                  flash ? 'FLASH AUTO' : 'FLASH OFF',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => setState(() => frontCamera = !frontCamera),
                icon: const Icon(
                  Icons.cameraswitch_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  category == 'Visiting Card'
                      ? 'assets/images/visiting_card.png'
                      : 'assets/images/storefront_camera.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.shade400,
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'DEMO CAMERA · Reference Preview (Hardware Camera Not Connected)',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 280,
                    height: category == 'Visiting Card' ? 180 : 280,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Center document or storefront inside guide frame',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final value in [
                  'Storefront',
                  'Visiting Card',
                  'Document',
                  'Site Inspection',
                  'General',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(value, style: const TextStyle(fontSize: 11)),
                      selected: category == value,
                      onSelected: (_) => setState(() => category = value),
                      showCheckmark: false,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 10, 26, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => open(context, '/photos'),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/images/office.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _capturePhoto,
                  iconSize: 72,
                  icon: const Icon(
                    Icons.radio_button_checked,
                    color: Colors.white,
                  ),
                  tooltip: 'Capture photo',
                ),
                TextButton(
                  onPressed: () => Navigator.maybePop(context),
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.white, fontSize: 15),
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

/// Legacy Photo Detail Screen for backward compatibility
class PhotoDetailScreen extends StatelessWidget {
  const PhotoDetailScreen({super.key, required this.photo});
  final ReferencePhoto photo;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: Text(
        photo.caption,
        style: const TextStyle(color: Colors.white, fontSize: 17),
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: InteractiveViewer(
            minScale: .8,
            maxScale: 5,
            child: Center(child: Image.asset(photo.asset, fit: BoxFit.contain)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '${photo.category} · Design reference photo',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

/// Legacy Voice Note recording screen for backward compatibility
class VoiceNoteScreen extends StatefulWidget {
  const VoiceNoteScreen({super.key, required this.visit});
  final Visit visit;
  @override
  State<VoiceNoteScreen> createState() => _VoiceNoteScreenState();
}

class _VoiceNoteScreenState extends State<VoiceNoteScreen> {
  bool transcribe = true;
  String speed = '1x', label = 'Meeting Notes';
  final transcript = TextEditingController();

  @override
  void dispose() {
    transcript.dispose();
    super.dispose();
  }

  void save() async {
    final noteText = transcript.text.trim().isNotEmpty
        ? transcript.text.trim()
        : 'Audio note recorded during ${widget.visit.type} with ${widget.visit.contact}. Key items captured.';

    final store = CrmStore.instance;
    final newRec = VoiceNoteRecord(
      title: '$label: ${widget.visit.company}',
      company: widget.visit.company,
      companyId: widget.visit.companyId,
      visitId: widget.visit.id,
      category: label,
      duration: '02:34',
      durationSeconds: 154,
      transcriptionStatus: transcribe ? 'Transcribed' : 'Processing',
      transcriptText: noteText,
    );

    try {
      await store.addVoiceNote(newRec);
      await store.addNote(widget.visit.company, '$label: $noteText');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice note recorded & transcribed!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save voice note: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => CrmPage(
    title: 'Voice Note',
    actions: [TextButton(onPressed: save, child: const Text('Save'))],
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.mic_none, color: Colors.amber, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'SIMULATED RECORDING (Demo Mode)\nHardware microphone & cloud speech-to-text API not connected.',
                style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
              ),
            ),
          ],
        ),
      ),
      gap(12),
      Center(child: muted('For: ${widget.visit.company} visit')),
      gap(30),
      SizedBox(
        height: 100,
        child: CustomPaint(painter: _WaveformPainter(progress: 0.6)),
      ),
      gap(20),
      Center(child: strong('02:34', 38)),
      Center(child: muted('/ 5:00 max duration')),
      gap(20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton.filledTonal(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Audio playback paused')),
            ),
            icon: const Icon(Icons.stop),
          ),
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.all(20),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recording simulated active')),
              );
            },
            icon: const Icon(Icons.mic, color: Colors.white),
          ),
          IconButton.filledTonal(
            onPressed: transcript.clear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      gap(15),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Transcribe this note with AI'),
        subtitle: const Text(
          'Automatically extract searchable text from audio',
        ),
        value: transcribe,
        onChanged: (v) => setState(() => transcribe = v),
      ),
      gap(10),
      TextField(
        controller: transcript,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: 'Transcript / Key Takeaways',
          hintText: 'Enter or review speech-to-text transcript...',
        ),
      ),
    ],
  );
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({this.progress = 0.5});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final activePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final inactivePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final barWidth = 6.0;
    final count = (size.width / barWidth).floor();
    final centerY = size.height / 2;

    for (var i = 0; i < count; i++) {
      final x = i * barWidth + barWidth / 2;
      final wave = (math.sin(i * 0.3) * 0.4 + math.cos(i * 0.15) * 0.6).abs();
      final h = math.max(6.0, wave * (size.height * 0.8));
      final isPlayed = (x / size.width) <= progress;

      canvas.drawLine(
        Offset(x, centerY - h / 2),
        Offset(x, centerY + h / 2),
        isPlayed ? activePaint : inactivePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
