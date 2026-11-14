import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_bottom_navigation.dart';
import '../../core/widgets/app_back_button.dart';
export '../../core/theme/app_colors.dart';
export '../../core/widgets/app_button.dart';

void open(BuildContext context, String route, [Object? arguments]) =>
    Navigator.of(context).pushNamed(route, arguments: arguments);
void tab(BuildContext context, int index) =>
    Navigator.of(context).pushNamedAndRemoveUntil(
      ['/dashboard', '/leads', '/visits', '/tasks', '/profile'][index],
      (r) => false,
    );
void message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

class CrmPage extends StatelessWidget {
  const CrmPage({
    super.key,
    required this.title,
    required this.children,
    this.nav,
    this.actions = const [],
    this.fab,
    this.leading,
    this.padding = true,
  });
  final String title;
  final List<Widget> children, actions;
  final int? nav;
  final Widget? fab, leading;
  final bool padding;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize:
              [
                'Leads',
                'Customers',
                'My Tasks',
                'Profile',
                'Settings',
              ].contains(title)
              ? 26
              : 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      centerTitle: nav == null,
      leading:
          leading ??
          (Navigator.canPop(context)
              ? const Center(child: AppBackButton())
              : null),
      actions: actions,
    ),
    body: ListView(
      padding: EdgeInsets.fromLTRB(
        padding ? 20 : 0,
        8,
        padding ? 20 : 0,
        fab == null ? 24 : 88,
      ),
      children: children,
    ),
    bottomNavigationBar: nav == null
        ? null
        : AppBottomNavigation(
            currentIndex: nav!,
            onTap: (i) => tab(context, i),
          ),
    floatingActionButton: fab,
  );
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.color = AppColors.surfaceSecondary,
    this.onTap,
    this.border = true,
    this.inset = 16,
  });
  final Widget child;
  final Color color;
  final VoidCallback? onTap;
  final bool border;
  final double inset;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(inset),
          decoration: BoxDecoration(
            border: border ? Border.all(color: AppColors.border) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    ),
  );
}

Widget gap([double h = 16]) => SizedBox(height: h);
Widget heading(String text, [Widget? trailing]) => Padding(
  padding: const EdgeInsets.only(top: 8, bottom: 12),
  child: Row(
    children: [
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      if (trailing != null) trailing,
    ],
  ),
);
Widget muted(String text) => Text(
  text,
  style: const TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    height: 1.5,
  ),
);
Widget strong(String text, [double size = 16]) => Text(
  text,
  style: TextStyle(fontWeight: FontWeight.w700, fontSize: size, height: 1.4),
);
Widget badge(String text, {Color color = AppColors.primary}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: color.withValues(alpha: .10),
    borderRadius: BorderRadius.circular(5),
  ),
  child: Text(
    text,
    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
  ),
);
Widget avatar(String text, {double radius = 22}) => Center(
  widthFactor: 1,
  heightFactor: 1,
  child: CircleAvatar(
    radius: radius,
    backgroundColor: AppColors.primaryLight,
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);
Widget actionIcon(IconData icon, VoidCallback onTap, {String? tooltip}) =>
    IconButton(onPressed: onTap, tooltip: tooltip, icon: Icon(icon, size: 21));
Widget button(String label, VoidCallback onTap, {bool secondary = false}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppButton(label: label, onPressed: onTap, isSecondary: secondary),
    );
Widget detail(String label, String value, {IconData? icon}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 9),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (icon != null) ...[
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            muted(label),
            gap(3),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
Widget linkRow(
  String title,
  IconData icon,
  VoidCallback onTap, {
  String? subtitle,
  Widget? trailing,
}) => ListTile(
  contentPadding: EdgeInsets.zero,
  leading: Icon(icon, color: AppColors.primary, size: 20),
  title: Text(
    title,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
  ),
  subtitle: subtitle == null ? null : muted(subtitle),
  trailing: trailing ?? const Icon(Icons.chevron_right, size: 18),
  onTap: onTap,
);
Widget chips(
  List<String> values,
  String selected,
  ValueChanged<String> onChanged,
) => SizedBox(
  height: 48,
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: values.length,
    separatorBuilder: (_, __) => const SizedBox(width: 7),
    itemBuilder: (_, i) => ChoiceChip(
      side: BorderSide(
        color: selected == values[i] ? AppColors.primary : AppColors.border,
      ),
      shape: const StadiumBorder(),
      label: Text(values[i], style: const TextStyle(fontSize: 11)),
      selected: selected == values[i],
      showCheckmark: false,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected == values[i] ? Colors.white : AppColors.primary,
      ),
      onSelected: (_) => onChanged(values[i]),
    ),
  ),
);
Widget emptyState(
  BuildContext context,
  String title,
  String description,
  IconData icon,
  String action,
  VoidCallback onTap,
) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 80),
  child: Column(
    children: [
      CircleAvatar(
        radius: 44,
        backgroundColor: const Color(0xFFF0FAF9),
        child: Icon(icon, size: 34, color: AppColors.primary),
      ),
      gap(26),
      strong(title, 20),
      gap(12),
      Text(
        description,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
      ),
      gap(28),
      button(action, onTap),
    ],
  ),
);
Future<bool> confirm(
  BuildContext context,
  String title,
  String body, {
  String action = 'Delete',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.error),
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

class FormFieldSpec {
  const FormFieldSpec(
    this.label, {
    String value = '',
    String? initial,
    this.required = false,
    this.options,
    this.lines = 1,
    this.section,
    this.pair,
    this.helper,
    this.caption,
    this.onAction,
    String kind = 'text',
    String? type,
  }) : value = initial ?? value,
       kind = type ?? kind;

  final String label, value, kind;
  final String? section, pair, helper, caption;
  final Future<String?> Function(BuildContext)? onAction;
  final bool required;
  final List<String>? options;
  final int lines;
}

class CrmForm extends StatefulWidget {
  const CrmForm({
    super.key,
    required this.title,
    required this.fields,
    required this.submit,
    required this.onSave,
    this.alternateSubmit,
    this.onDelete,
  });
  final String title, submit;
  final String? alternateSubmit;
  final Future<void> Function(BuildContext)? onDelete;
  final List<FormFieldSpec> fields;
  final Future<void> Function(BuildContext, Map<String, String>) onSave;
  @override
  State<CrmForm> createState() => _CrmFormState();
}

class _CrmFormState extends State<CrmForm> {
  final key = GlobalKey<FormState>();
  late final Map<String, TextEditingController> controllers = {
    for (final f in widget.fields)
      f.label: TextEditingController(text: f.value),
  };
  bool saving = false, reminder = true;
  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save({bool alternate = false}) async {
    if (!key.currentState!.validate() || saving) return;
    setState(() => saving = true);
    try {
      await widget.onSave(context, {
        ...controllers.map((k, v) => MapEntry(k, v.text.trim())),
        '_scheduleVisit': '$alternate',
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> pickDate(FormFieldSpec f) async {
    final existing =
        DateTime.tryParse(controllers[f.label]!.text) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: existing,
      firstDate: DateTime(2020),
      lastDate: DateTime(2036),
    );
    if (date == null || !mounted) return;
    var result = date;
    if (f.kind == 'datetime') {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(existing),
      );
      if (time == null || !mounted) return;
      result = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }
    setState(
      () => controllers[f.label]!.text = f.kind == 'datetime'
          ? result.toIso8601String()
          : result.toIso8601String().split('T').first,
    );
  }

  Future<void> attach(FormFieldSpec f) async {
    try {
      final files = await openFiles();
      final stored = controllers[f.label]!.text.isEmpty
          ? <dynamic>[]
          : jsonDecode(controllers[f.label]!.text) as List;
      for (final file in files) {
        final bytes = await file.readAsBytes();
        if (bytes.length > 10 * 1024 * 1024) {
          if (mounted)
            message(context, '${file.name}: maximum file size is 10 MB');
          continue;
        }
        stored.add({
          'name': file.name,
          'bytes': base64Encode(bytes),
          'mime': file.mimeType ?? 'application/octet-stream',
        });
      }
      if (mounted)
        setState(() => controllers[f.label]!.text = jsonEncode(stored));
    } catch (e) {
      if (mounted) message(context, 'Unable to attach file: $e');
    }
  }

  Widget field(FormFieldSpec f) {
    final controller = controllers[f.label]!;
    Widget control;
    if (f.kind == 'action') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: OutlinedButton.icon(
          onPressed: () async {
            final result = await f.onAction?.call(context);
            if (result != null && mounted) {
              setState(() => controller.text = result);
              message(context, '${f.label}: $result');
            }
          },
          icon: const Icon(Icons.add_circle_outline),
          label: Text(f.label),
        ),
      );
    } else if (f.kind == 'toggle') {
      return SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(f.label, style: const TextStyle(fontSize: 14)),
        subtitle: f.helper == null
            ? null
            : Text(f.helper!, style: const TextStyle(fontSize: 11)),
        value: controller.text == 'true',
        onChanged: (v) => setState(() => controller.text = '$v'),
      );
    } else if (f.kind == 'attachments') {
      final files = controller.text.isEmpty
          ? <dynamic>[]
          : jsonDecode(controller.text) as List;
      control = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: () => attach(f),
            icon: const Icon(Icons.attach_file),
            label: const Text('Add File'),
          ),
          for (var i = 0; i < files.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: Text(
                files[i]['name'] as String,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                tooltip: 'Remove attachment',
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  files.removeAt(i);
                  controller.text = jsonEncode(files);
                }),
              ),
            ),
        ],
      );
    } else if (f.kind == 'chips') {
      control = Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          for (final v in f.options!)
            ChoiceChip(
              label: Text(
                v,
                style: TextStyle(
                  fontSize: 11,
                  color: controller.text == v
                      ? Colors.white
                      : AppColors.primary,
                ),
              ),
              showCheckmark: false,
              selectedColor: AppColors.primary,
              selected: controller.text == v,
              onSelected: (_) => setState(() => controller.text = v),
            ),
        ],
      );
    } else if (f.kind == 'slider') {
      final value = (double.tryParse(controller.text) ?? 50).clamp(0.0, 100.0);
      control = Column(
        children: [
          Slider(
            value: value,
            max: 100,
            divisions: 100,
            label: '${value.round()}%',
            onChanged: (v) => setState(() => controller.text = '${v.round()}'),
          ),
          Text('${value.round()}%'),
        ],
      );
    } else if (f.kind == 'date' || f.kind == 'datetime') {
      final date = DateTime.tryParse(controller.text);
      final formatted = date == null
          ? 'Select ${f.kind == 'datetime' ? 'date & time' : 'date'}'
          : '${MaterialLocalizations.of(context).formatMediumDate(date)}${f.kind == 'datetime' ? ' · ${TimeOfDay.fromDateTime(date).format(context)}' : ''}';
      control = FormField<String>(
        initialValue: controller.text,
        validator: (_) => f.required && controller.text.isEmpty
            ? '${f.label} is required'
            : null,
        builder: (state) => InkWell(
          onTap: () => pickDate(f),
          child: InputDecorator(
            decoration: InputDecoration(
              errorText: state.errorText,
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
            ),
            child: Text(formatted, style: const TextStyle(fontSize: 13)),
          ),
        ),
      );
    } else if (f.options != null) {
      control = DropdownButtonFormField<String>(
        initialValue: f.options!.contains(controller.text)
            ? controller.text
            : null,
        isExpanded: true,
        hint: Text('Select ${f.label.toLowerCase()}'),
        items: f.options!
            .toSet()
            .map(
              (v) => DropdownMenuItem(
                value: v,
                child: Text(v, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (v) => controller.text = v ?? '',
        validator: (v) => f.required && (v == null || v.isEmpty)
            ? 'Please select ${f.label.toLowerCase()}'
            : null,
      );
    } else {
      control = TextFormField(
        controller: controller,
        maxLines: f.kind == 'password' ? 1 : f.lines,
        obscureText: f.kind == 'password',
        readOnly: ['date', 'datetime', 'readonly'].contains(f.kind),
        keyboardType: f.kind == 'number'
            ? TextInputType.number
            : f.kind == 'email'
            ? TextInputType.emailAddress
            : TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Enter ${f.label.toLowerCase()}',
          suffixIcon: ['date', 'datetime'].contains(f.kind)
              ? const Icon(Icons.calendar_today, size: 18)
              : null,
        ),
        onTap: ['date', 'datetime'].contains(f.kind) ? () => pickDate(f) : null,
        validator: (v) {
          final value = v?.trim() ?? '';
          if (f.required && value.isEmpty) return '${f.label} is required';
          if (value.isNotEmpty &&
              f.kind == 'email' &&
              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value))
            return 'Enter a valid email address';
          if (f.kind == 'number' &&
              (double.tryParse(value.replaceAll(',', '')) == null ||
                  double.parse(value.replaceAll(',', '')) < 0))
            return 'Enter a valid positive number';
          return null;
        },
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${f.caption ?? f.label}${f.required ? ' *' : ''}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          gap(8),
          control,
          if (f.helper != null) ...[gap(6), muted(f.helper!)],
        ],
      ),
    );
  }

  List<Widget> formFields() {
    final result = <Widget>[];
    for (var i = 0; i < widget.fields.length; i++) {
      final f = widget.fields[i];
      if (f.section != null)
        result.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: heading(f.section!),
          ),
        );
      if (f.pair != null &&
          i + 1 < widget.fields.length &&
          widget.fields[i + 1].pair == f.pair) {
        result.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: field(f)),
              const SizedBox(width: 12),
              Expanded(child: field(widget.fields[++i])),
            ],
          ),
        );
      } else {
        result.add(field(f));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      leading: Navigator.canPop(context)
          ? const Center(child: AppBackButton())
          : null,
      actions: [
        TextButton(
          onPressed: saving ? null : () => save(),
          child: const Text('Save'),
        ),
      ],
    ),
    body: Form(
      key: key,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...formFields(),
          AppButton(
            label: widget.submit,
            isLoading: saving,
            onPressed: () => save(),
          ),
          if (widget.alternateSubmit != null) ...[
            gap(12),
            OutlinedButton(
              onPressed: saving ? null : () => save(alternate: true),
              child: Text(widget.alternateSubmit!),
            ),
          ],
          if (widget.onDelete != null) ...[
            gap(12),
            TextButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (await confirm(
                            context,
                            'Delete ${widget.title.replaceFirst('Edit ', '')}?',
                            'This cannot be undone.',
                            action: 'Delete',
                          ) &&
                          context.mounted) {
                        try {
                          await widget.onDelete!(context);
                        } catch (e) {
                          if (context.mounted)
                            message(context, 'Failed to delete: $e');
                        }
                      }
                    },
              child: Text(
                'Delete ${widget.title.replaceFirst('Edit ', '')}',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
          gap(24),
        ],
      ),
    ),
  );
}
