import 'package:flutter/material.dart';

import 'state.dart';

const red = Color(0xffff2700);
const coral = Color(0xffff6f58);
const tint = Color(0xffffefeb);
const ink = Color(0xff171717);
const muted = Color(0xff797570);
const white = Color(0xfffefefe);
const gutter = 20.0;

TextStyle type(
  double size, {
  Color color = ink,
  FontWeight weight = FontWeight.w500,
  double height = 1.32,
}) {
  return TextStyle(
    fontSize: size,
    color: color,
    fontWeight: weight,
    height: height,
  );
}

class Photo extends StatelessWidget {
  const Photo(
    this.name, {
    super.key,
    this.height,
    this.width,
    this.radius = 12,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String name;
  final double? height, width;
  final double radius;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        'assets/images/$name.webp',
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        excludeFromSemantics: true,
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton(
    this.label,
    this.onPressed, {
    super.key,
    this.light = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool light;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: light ? tint : red,
          foregroundColor: light ? red : Colors.white,
          disabledBackgroundColor: const Color(0xfff3e6e3),
          disabledForegroundColor: const Color(0xff806f6b),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: .55,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17),
              const SizedBox(width: 8),
            ],
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}

class MiniAction extends StatelessWidget {
  const MiniAction(this.label, this.onTap, {super.key, this.background = true});

  final String label;
  final VoidCallback onTap;
  final bool background;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: red,
        backgroundColor: background ? tint : Colors.transparent,
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(label, style: type(12, color: red)),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader(
    this.title, {
    super.key,
    this.dismiss = false,
    this.back = true,
    this.trailing,
    this.onBack,
  });

  final String title;
  final bool dismiss, back;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 92),
            child: Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: type(15, color: red, weight: FontWeight.w600),
            ),
          ),
          if (back)
            Positioned(
              left: 9,
              child: IconButton(
                tooltip: dismiss ? 'Close' : 'Back',
                onPressed: onBack ?? context.close,
                icon: Icon(
                  dismiss ? Icons.close : Icons.chevron_left,
                  color: red,
                  size: 24,
                ),
              ),
            ),
          if (trailing != null) Positioned(right: gutter, child: trailing!),
        ],
      ),
    );
  }
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.body,
    this.header,
    this.footer,
    this.tab,
    this.resize = true,
    this.topInset = 40,
  });

  final Widget body;
  final Widget? header, footer;
  final int? tab;
  final bool resize;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resize,
      body: SafeArea(
        minimum: EdgeInsets.only(top: topInset),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                ?header,
                Expanded(child: body),
                ?footer,
                if (tab != null) AppTabs(tab!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppTabs extends StatelessWidget {
  const AppTabs(this.selected, {super.key});

  final int selected;
  static const labels = ['GraBite', 'Search', 'Orders', 'Profile'];
  static const icons = [
    Icons.restaurant,
    Icons.search,
    Icons.receipt,
    Icons.person,
  ];
  static const screens = [
    Screen.home,
    Screen.search,
    Screen.orders,
    Screen.account,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0f201511),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final color = i == selected ? red : coral;
          return Expanded(
            child: Semantics(
              selected: i == selected,
              button: true,
              child: InkWell(
                onTap: () => context.reset(screens[i]),
                child: SizedBox(
                  height: 62,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (i == 0)
                        const Photo(
                          'mark',
                          width: 24,
                          height: 24,
                          radius: 0,
                          fit: BoxFit.contain,
                        )
                      else
                        Icon(icons[i], color: color, size: 21),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: type(
                          11,
                          color: color,
                          weight: i == selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 3,
                        width: 26,
                        decoration: BoxDecoration(
                          color: i == selected ? red : Colors.transparent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ContentList extends StatelessWidget {
  const ContentList(
    this.children, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(gutter, 16, gutter, 24),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) =>
      ListView(padding: padding, children: children);
}

class Foot extends StatelessWidget {
  const Foot(this.child, {super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(gutter, 9, gutter, 16),
      child: child,
    );
  }
}

class IntroText extends StatelessWidget {
  const IntroText(
    this.title,
    this.description, {
    super.key,
    this.center = false,
  });

  final String title, description;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: type(30, color: coral),
        ),
        const SizedBox(height: 14),
        Text(
          description,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: type(13, color: muted, height: 1.65),
        ),
      ],
    );
  }
}

class Field extends StatefulWidget {
  const Field(
    this.hint,
    this.controller, {
    super.key,
    this.icon,
    this.trailing,
    this.keyboardType,
    this.secret = false,
    this.highlight = false,
    this.autofocus = false,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.action,
    this.prefix,
  });

  final String hint;
  final TextEditingController controller;
  final IconData? icon, trailing;
  final TextInputType? keyboardType;
  final bool secret, highlight, autofocus;
  final int? maxLength;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged, onSubmitted;
  final TextInputAction? action;
  final Widget? prefix;

  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  bool reveal = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.secret && !reveal,
      autofocus: widget.autofocus,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.action,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      style: type(13, color: widget.highlight ? red : ink),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: widget.highlight ? tint : const Color(0xfff4f4f4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: coral),
        ),
        hintText: widget.hint,
        hintStyle: type(13, color: widget.highlight ? coral : muted),
        prefixIcon:
            widget.prefix ??
            (widget.icon == null
                ? null
                : Icon(widget.icon, color: coral, size: 19)),
        suffixIcon: widget.secret
            ? IconButton(
                tooltip: reveal ? 'Hide password' : 'Show password',
                icon: Icon(
                  reveal ? Icons.visibility : Icons.visibility_off_outlined,
                  size: 17,
                  color: widget.highlight ? red : muted,
                ),
                onPressed: () => setState(() => reveal = !reveal),
              )
            : widget.trailing == null
            ? null
            : Icon(widget.trailing, size: 19, color: coral),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
      ),
    );
  }
}

class TintRow extends StatelessWidget {
  const TintRow(
    this.title, {
    super.key,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.strong = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading, trailing;
  final VoidCallback? onTap;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: tint,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            child: Row(
              children: [
                if (leading != null || icon != null) ...[
                  leading ?? Icon(icon, color: red, size: 19),
                  const SizedBox(width: 13),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: type(
                          13,
                          color: strong ? ink : coral,
                          weight: strong ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: type(11, color: strong ? muted : coral),
                        ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (onTap != null)
                  const Icon(Icons.chevron_right, color: red, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.title, {
    super.key,
    this.action,
    this.onTap,
    this.size = 23,
  });

  final String title;
  final String? action;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: type(size, weight: FontWeight.w600)),
          ),
          if (action != null && onTap != null) ...[
            const SizedBox(width: 8),
            MiniAction(action!, onTap!),
          ],
        ],
      ),
    );
  }
}

class RatingPill extends StatelessWidget {
  const RatingPill(this.rating, {super.key});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: red,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          rating.toStringAsFixed(1),
          style: type(
            11,
            color: Colors.white,
            weight: FontWeight.w700,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

class ChoicePill extends StatelessWidget {
  const ChoicePill(
    this.label,
    this.selected,
    this.onTap, {
    super.key,
    this.circle = false,
  });

  final String label;
  final bool selected, circle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: Size(circle ? 52 : 60, circle ? 52 : 37),
        backgroundColor: selected ? red : tint,
        foregroundColor: selected ? Colors.white : coral,
        shape: circle
            ? const CircleBorder(side: BorderSide(color: Color(0xffffc8bc)))
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

Widget space(double size) => SizedBox(height: size);
