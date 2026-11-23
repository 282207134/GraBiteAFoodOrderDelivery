import 'package:flutter/material.dart';

import '../core/state.dart';
import '../core/ui.dart';
import '../data/catalog.dart';
import 'discovery.dart';

class FilterPage extends StatefulWidget {
  const FilterPage(this.screen, {super.key});
  final Screen screen;

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late FilterValues draft = context.state.filters;
  late int tab = switch (widget.screen) {
    Screen.filterSort => 1,
    Screen.filterPrice => 2,
    _ => 0,
  };

  void apply() {
    final state = context.state;
    state.filters = draft;
    if (widget.screen == Screen.filters) {
      state.changed();
      context.close();
    } else {
      state.search = '';
      state.changed();
      context.open(Screen.resultsList, replace: true);
    }
  }

  void update(FilterValues filters) => setState(() => draft = filters);

  Widget selectCategories() => Wrap(
    spacing: 9,
    runSpacing: 9,
    children: [
      for (final category in foodTypes)
        ChoicePill(
          category.toUpperCase(),
          draft.category == category,
          () => update(draft.copyWith(category: category)),
        ),
    ],
  );

  Widget selectDiets() => Wrap(
    spacing: 9,
    runSpacing: 9,
    children: [
      for (final diet in diets)
        ChoicePill(
          diet.toUpperCase(),
          draft.diet == diet,
          () => update(draft.copyWith(diet: diet)),
        ),
    ],
  );

  Widget pricePills() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (var price = 1; price <= 5; ++price)
          Padding(
            padding: const EdgeInsets.only(right: 11),
            child: ChoicePill(
              '\$' * price,
              draft.price == price,
              () => update(
                draft.copyWith(price: draft.price == price ? 0 : price),
              ),
              circle: true,
            ),
          ),
      ],
    ),
  );

  Widget typeTiles() {
    const entries = [
      ('Burgers', 'burgers', 120),
      ('Pizza', 'pasta', 187),
      ('Soups', 'hero-soup', 123),
      ('Salads', 'salad', 64),
    ];
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final (category, image, total) = entries[index];
          return InkWell(
            onTap: () => update(
              draft.copyWith(
                category: draft.category == category ? 'All' : category,
              ),
            ),
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(
              width: 105,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Photo(image, height: 110, width: 105),
                        if (draft.category == category)
                          const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.check_circle,
                              color: red,
                              size: 23,
                            ),
                          ),
                      ],
                    ),
                  ),
                  space(7),
                  Text.rich(
                    TextSpan(
                      text: '$category ',
                      style: type(12),
                      children: [
                        TextSpan(
                          text: '($total)',
                          style: type(12, color: red),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget sortOptions() => Column(
    children: [
      for (var i = 0; i < sorts.length; i++)
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: Icon(
            [Icons.star, Icons.delivery_dining, Icons.favorite][i],
            size: 18,
            color: red,
          ),
          title: Text(sorts[i], style: type(14)),
          trailing: Icon(
            draft.sort == sorts[i]
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: red,
            size: 19,
          ),
          onTap: () => update(draft.copyWith(sort: sorts[i])),
        ),
    ],
  );

  Widget selectPrice() {
    const labels = ['\$1', '\$3', '\$5', '\$7', '\$10', '\$10+'];
    const maximum = [1, 3, 5, 7, 10, 11];
    final value = draft.fee == 5 ? 2 : maximum.indexOf(draft.fee);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Max Delivery Fee', style: type(15)),
        space(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final label in labels)
              Text(label, style: type(10, color: muted)),
          ],
        ),
        Slider(
          min: 0,
          max: 5,
          divisions: 5,
          value: value < 0 ? 5 : value.toDouble(),
          activeColor: red,
          inactiveColor: tint,
          onChanged: (value) =>
              update(draft.copyWith(fee: maximum[value.round()])),
        ),
        Text('Price Range', style: type(15)),
        space(13),
        pricePills(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final full = widget.screen == Screen.filters;
    if (full) {
      return PageFrame(
        header: const ScreenHeader('Filters'),
        footer: Foot(ActionButton('APPLY FILTERS', apply)),
        body: ContentList([
          SectionTitle(
            'CATEGORIES',
            size: 15,
            action: 'CLEAR ALL',
            onTap: () => update(draft.copyWith(category: 'All')),
          ),
          selectCategories(),
          space(29),
          SectionTitle(
            'DIETARY',
            size: 15,
            action: 'CLEAR ALL',
            onTap: () => update(draft.copyWith(diet: 'Any')),
          ),
          selectDiets(),
          space(29),
          SectionTitle(
            'PRICE RANGE',
            size: 15,
            action: 'CLEAR ALL',
            onTap: () => update(draft.copyWith(price: 0)),
          ),
          pricePills(),
        ]),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          const IgnorePointer(child: HomePage(Screen.home)),
          Positioned.fill(
            child: GestureDetector(
              onTap: context.close,
              child: const ColoredBox(color: Color(0x77000000)),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Material(
                  color: white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScreenHeader(
                          '',
                          dismiss: true,
                          trailing: MiniAction(
                            'CLEAR ALL',
                            () => update(const FilterValues()),
                          ),
                        ),
                        Row(
                          children: [
                            for (final (index, title) in [
                              'Type',
                              'Sort by',
                              'Price',
                              'Dietary',
                            ].indexed)
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => tab = index),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Text(
                                          title,
                                          style: type(13, color: coral),
                                        ),
                                      ),
                                      Container(
                                        color: tab == index ? coral : tint,
                                        height: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            gutter,
                            17,
                            gutter,
                            17,
                          ),
                          child: Column(
                            children: [
                              switch (tab) {
                                0 => typeTiles(),
                                1 => sortOptions(),
                                2 => selectPrice(),
                                _ => selectDiets(),
                              },
                              space(15),
                              ActionButton('COMPLETE', apply, light: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
