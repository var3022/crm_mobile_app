import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_bottom_navigation.dart';
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
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
      centerTitle: nav == null,
      leading: leading,
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
  });
  final Widget child;
  final Color color;
  final VoidCallback? onTap;
  final bool border;
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
          padding: const EdgeInsets.all(16),
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
    this.value = '',
    this.required = false,
    this.options,
    this.lines = 1,
    this.kind = 'text',
  });
  final String label, value, kind;
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
  });
  final String title, submit;
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

  Future<void> save() async {
    if (!key.currentState!.validate() || saving) return;
    setState(() => saving = true);
    try {
      await widget.onSave(
        context,
        controllers.map((k, v) => MapEntry(k, v.text.trim())),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      actions: [
        TextButton(onPressed: saving ? null : save, child: const Text('Save')),
      ],
    ),
    body: Form(
      key: key,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final f in widget.fields) ...[
            Text(
              '${f.label}${f.required ? ' *' : ''}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            gap(8),
            if (f.options != null)
              DropdownButtonFormField<String>(
                initialValue: f.options!.contains(controllers[f.label]!.text)
                    ? controllers[f.label]!.text
                    : null,
                isExpanded: true,
                hint: Text('Select ${f.label.toLowerCase()}'),
                items: f.options!
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (v) => controllers[f.label]!.text = v ?? '',
                validator: (v) => f.required && (v == null || v.isEmpty)
                    ? 'Please select ${f.label.toLowerCase()}'
                    : null,
              )
            else
              TextFormField(
                controller: controllers[f.label],
                maxLines: f.kind == 'password' ? 1 : f.lines,
                obscureText: f.kind == 'password',
                readOnly: f.kind == 'date',
                keyboardType: f.kind == 'number'
                    ? TextInputType.number
                    : f.kind == 'email'
                    ? TextInputType.emailAddress
                    : TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Enter ${f.label.toLowerCase()}',
                  suffixIcon: f.kind == 'date'
                      ? const Icon(Icons.calendar_today, size: 18)
                      : null,
                ),
                onTap: f.kind == 'date'
                    ? () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 730),
                          ),
                        );
                        if (date != null)
                          controllers[f.label]!.text =
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                      }
                    : null,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (f.required && value.isEmpty)
                    return '${f.label} is required';
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
              ),
            gap(20),
          ],
          AppButton(label: widget.submit, isLoading: saving, onPressed: save),
          gap(20),
        ],
      ),
    ),
  );
}
