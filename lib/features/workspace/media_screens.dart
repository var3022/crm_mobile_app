import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'crm_store.dart';
import 'crm_ui.dart';

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

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});
  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  String category = 'All';
  @override
  Widget build(BuildContext context) {
    final photos = referencePhotos
        .where((p) => category == 'All' || p.category == category)
        .toList();
    return CrmPage(
      title: 'Photos',
      actions: [
        actionIcon(
          Icons.photo_camera_outlined,
          () => open(context, '/camera'),
          tooltip: 'Open camera preview',
        ),
      ],
      children: [
        chips(
          ['All', 'Visiting Card', 'Store Front', 'Product', 'General'],
          category,
          (v) => setState(() => category = v),
        ),
        gap(10),
        muted('Reference photos from the design · ${photos.length} photos'),
        gap(15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: photos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 14,
            childAspectRatio: .82,
          ),
          itemBuilder: (context, index) {
            final photo = photos[index];
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PhotoDetailScreen(photo: photo),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        photo.asset,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  gap(6),
                  Text(
                    photo.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  muted(photo.category),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

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

class CameraPreviewScreen extends StatefulWidget {
  const CameraPreviewScreen({super.key});
  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  String category = 'General';
  bool flash = true;
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
                onPressed: () => message(
                  context,
                  'Camera switching requires a device camera service.',
                ),
                icon: const Icon(
                  Icons.cameraswitch_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Expanded(
            child: Image.asset(
              'assets/images/storefront_camera.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Design reference preview · Camera not connected',
              style: TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final value in [
                  'General',
                  'Visiting Card',
                  'Store Front',
                  'Product Display',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(value, style: const TextStyle(fontSize: 10)),
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
                      'assets/images/visiting_card.png',
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => message(
                    context,
                    'Connect the camera service to capture a new photo. No photo was taken.',
                  ),
                  iconSize: 68,
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
                    style: TextStyle(color: Colors.white),
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

  void save() {
    if (transcript.text.trim().isEmpty) {
      message(
        context,
        'Add a text transcript to save. Audio recording is not connected.',
      );
      return;
    }
    CrmStore.instance.addNote(
      widget.visit.company,
      '$label: ${transcript.text.trim()}',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => CrmPage(
    title: 'Voice Note',
    actions: [TextButton(onPressed: save, child: const Text('Save'))],
    children: [
      Center(child: muted('For: ${widget.visit.company} visit')),
      gap(40),
      SizedBox(height: 120, child: CustomPaint(painter: _WaveformPainter())),
      gap(25),
      Center(child: strong('02:34', 42)),
      Center(child: muted('/ 5:00 max duration')),
      gap(24),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton.filledTonal(
            onPressed: () =>
                message(context, 'No audio is loaded in this preview.'),
            icon: const Icon(Icons.stop),
          ),
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.all(20),
            ),
            onPressed: () => message(
              context,
              'A microphone recording service must be connected before recording.',
            ),
            icon: const Icon(Icons.mic_none),
          ),
          IconButton.filledTonal(
            onPressed: transcript.clear,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      gap(15),
      Center(child: muted('Reference waveform · No audio is being recorded')),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Transcribe this note',
          style: TextStyle(fontSize: 13),
        ),
        value: transcribe,
        onChanged: (v) => setState(() => transcribe = v),
      ),
      heading('Quick Labels'),
      chips(
        ['Meeting Notes', 'Action Items', 'Follow-up', 'Playback Speed'],
        label,
        (v) => setState(() => label = v),
      ),
      heading('Playback Speed'),
      chips(['1x', '1.5x', '2x'], speed, (v) => setState(() => speed = v)),
      heading('Text Transcript'),
      TextField(
        controller: transcript,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText:
              'Enter the note as text while audio recording is unavailable...',
        ),
      ),
      gap(20),
      button('Save Text Note', save),
    ],
  );
}

class _WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 35; i++) {
      final x = size.width / 2 + (i - 17) * 5;
      final envelope = 1 - (i - 17).abs() / 18;
      final height = 8 + math.sin(i * 1.7).abs() * 85 * envelope;
      canvas.drawLine(
        Offset(x, (size.height - height) / 2),
        Offset(x, (size.height + height) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
