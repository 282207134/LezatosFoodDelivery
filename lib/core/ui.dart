import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const orange = Color(0xffff431c);
const ink = Color(0xff191b27);
const muted = Color(0xff808d9e);
const line = Color(0xffeaedf2);
const soft = Color(0xfff5f6fa);
const flame = LinearGradient(
  colors: [Color(0xffffa146), Color(0xffff4759)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const gutter = EdgeInsets.symmetric(horizontal: 20);

TextStyle type(
  double size, {
  Color color = ink,
  FontWeight weight = FontWeight.w600,
  double? height,
}) =>
    TextStyle(fontSize: size, color: color, fontWeight: weight, height: height);

Widget label(
  String value, {
  double size = 14,
  Color color = ink,
  FontWeight weight = FontWeight.w600,
  TextAlign? align,
  int? maxLines,
}) => Text(
  value,
  style: type(size, color: color, weight: weight, height: 1.25),
  textAlign: align,
  maxLines: maxLines,
  overflow: maxLines == null ? null : TextOverflow.ellipsis,
);

Widget heading(String value, {double size = 24, TextAlign? align}) =>
    label(value, size: size, weight: FontWeight.w700, align: align);

Widget art(
  String name, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Alignment alignment = Alignment.center,
}) => Image.asset(
  'assets/images/$name.webp',
  width: width,
  height: height,
  fit: fit,
  alignment: alignment,
  excludeFromSemantics: true,
);

Widget photo(
  String name, {
  double? width,
  double? height,
  double radius = 14,
  BoxFit fit = BoxFit.cover,
}) => ClipRRect(
  borderRadius: BorderRadius.circular(radius),
  child: art(name, width: width, height: height, fit: fit),
);

Widget action(String text, VoidCallback? onTap, {Color color = orange}) =>
    SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
        ),
        child: label(text, color: Colors.white, weight: FontWeight.w700),
      ),
    );

Widget link(String text, VoidCallback onTap, {Color color = orange}) =>
    TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: const Size(36, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: label(text, color: color, weight: FontWeight.w700),
    );

Widget iconAction(
  IconData icon,
  String tooltip,
  VoidCallback onTap, {
  Color color = ink,
  Color? background,
  double size = 24,
}) => IconButton(
  onPressed: onTap,
  tooltip: tooltip,
  style: IconButton.styleFrom(
    backgroundColor: background,
    minimumSize: const Size(44, 44),
  ),
  icon: Icon(icon, color: color, size: size),
);

Widget toolbar(
  String title,
  VoidCallback back, {
  Widget? trailing,
  bool showBack = true,
  Color color = ink,
}) => SizedBox(
  height: 56,
  child: Stack(
    alignment: Alignment.center,
    children: [
      Center(
        child: label(title, size: 18, color: color, weight: FontWeight.w700),
      ),
      if (showBack)
        Positioned(
          left: 9,
          child: iconAction(
            Icons.arrow_back_ios_new_rounded,
            'Back',
            back,
            color: color,
            size: 19,
          ),
        ),
      if (trailing != null) Positioned(right: 16, child: trailing),
    ],
  ),
);

Widget section(String text, {String? actionText, VoidCallback? onTap}) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    heading(text, size: 18),
    if (actionText != null && onTap != null) link(actionText, onTap),
  ],
);

Widget panel({
  required Widget child,
  Color color = Colors.white,
  Color? border,
  double radius = 16,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
}) => Container(
  padding: padding,
  decoration: BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: border == null ? null : Border.all(color: border),
  ),
  child: child,
);

class FormFieldPill extends StatefulWidget {
  const FormFieldPill({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.secret = false,
    this.type = TextInputType.text,
    this.onChanged,
    this.onSubmit,
    this.focusNode,
    this.action = TextInputAction.next,
    this.trailing,
    this.highlighted = false,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final bool secret;
  final TextInputType type;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmit;
  final FocusNode? focusNode;
  final TextInputAction action;
  final Widget? trailing;
  final bool highlighted;

  @override
  State<FormFieldPill> createState() => _FormFieldPillState();
}

class _FormFieldPillState extends State<FormFieldPill> {
  bool visible = false;

  @override
  Widget build(BuildContext context) => TextField(
    controller: widget.controller,
    focusNode: widget.focusNode,
    onChanged: widget.onChanged,
    keyboardType: widget.type,
    textInputAction: widget.action,
    onSubmitted: widget.onSubmit,
    obscureText: widget.secret && !visible,
    style: type(14, weight: FontWeight.w700),
    decoration: InputDecoration(
      hintText: widget.hint,
      hintStyle: type(14, color: muted, weight: FontWeight.w400),
      prefixIcon: widget.icon == null
          ? null
          : Icon(widget.icon, color: muted, size: 20),
      suffixIcon: widget.secret
          ? iconAction(
              visible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              visible ? 'Hide password' : 'Show password',
              () => setState(() => visible = !visible),
              color: muted,
            )
          : widget.trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide(
          color: widget.highlighted ? const Color(0xff5667dd) : line,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: Color(0xff5667dd)),
      ),
    ),
  );
}

Widget verticalBody(
  List<Widget> children, {
  EdgeInsetsGeometry padding = gutter,
}) => ListView(padding: padding, children: children);

Widget footer(Widget button, {Widget? secondary}) => Padding(
  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
  child: Column(mainAxisSize: MainAxisSize.min, children: [button, ?secondary]),
);

Widget systemStyle(Widget child, {bool light = false}) =>
    AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: light ? Brightness.light : Brightness.dark,
        statusBarBrightness: light ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: child,
    );

void notice(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

Future<void> info(BuildContext context, String title, String message) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
