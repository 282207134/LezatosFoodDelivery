import 'package:flutter/material.dart';

import '../core/session.dart';
import '../core/ui.dart';
import '../data/design.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker(this.session, {super.key});
  final Session session;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  static const places = [
    ('Bancangan, Sambit', 'Etan Telkom Mbibis'),
    ('Bancar, Bungkal', 'Ponorogo, East Java'),
  ];

  late final input = TextEditingController(
    text: widget.session.screen == Screen.locationTyping ? 'Banca' : '',
  );
  bool showMap = false;

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void apply(String location, String address) {
    widget.session.location = location;
    widget.session.address = address;
    widget.session.back();
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = input.text.trim().isNotEmpty;
    final results = places.where(
      (place) =>
          place.$1.toLowerCase().contains(input.text.trim().toLowerCase()),
    );
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 358,
          child: art('location_map', alignment: Alignment.topCenter),
        ),
        Column(
          children: [
            toolbar(
              'Select Your Location',
              widget.session.back,
              trailing: link(
                showMap ? 'List' : 'On Map',
                () => setState(() => showMap = !showMap),
              ),
            ),
            Expanded(
              child: verticalBody([
                const SizedBox(height: 16),
                FormFieldPill(
                  controller: input,
                  hint: 'Search location',
                  icon: Icons.search_rounded,
                  onChanged: (_) => setState(() {}),
                  action: TextInputAction.go,
                  onSubmit: (value) {
                    if (value.trim().isNotEmpty) {
                      apply(value.trim(), value.trim());
                    }
                  },
                  trailing: hasQuery
                      ? iconAction(
                          Icons.close,
                          'Clear location',
                          () => setState(input.clear),
                          size: 18,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    _chip(
                      Icons.home_outlined,
                      'At Home',
                      'Bancangan, Sambit',
                      widget.session.address,
                    ),
                    _chip(
                      Icons.work_outline,
                      'At Work',
                      'Ponorogo',
                      'Jl. Jendral Sudirman no. 80 A, Ponorogo',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (showMap) ...[
                  photo('address_map', height: 260),
                  const SizedBox(height: 12),
                  action(
                    'Use this location',
                    () =>
                        apply(widget.session.location, widget.session.address),
                  ),
                ] else if (hasQuery) ...[
                  for (final place in results)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.location_on_rounded,
                        color: orange,
                        size: 18,
                      ),
                      title: heading(place.$1, size: 15),
                      subtitle: label(place.$2, color: muted, size: 12),
                      onTap: () => apply(place.$1, place.$2),
                    ),
                  if (results.isEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: orange,
                      ),
                      title: heading('Use “${input.text.trim()}”', size: 15),
                      onTap: () => apply(input.text.trim(), input.text.trim()),
                    ),
                ],
              ]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String text, String location, String address) =>
      ActionChip(
        label: label(text, size: 13),
        avatar: Icon(icon, color: orange, size: 17),
        backgroundColor: Colors.white,
        side: const BorderSide(color: line),
        shape: const StadiumBorder(),
        onPressed: () => apply(location, address),
      );
}
