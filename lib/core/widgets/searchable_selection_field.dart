import 'package:flutter/material.dart';

/// A compact form field that opens a searchable list of context-specific
/// choices. It is intentionally generic so every feature can use the same
/// accessible picker while supplying only relevant options.
class SearchableSelectionField<T> extends FormField<T> {
  SearchableSelectionField({
    super.key,
    required List<T> options,
    required String labelText,
    required String Function(T value) itemLabel,
    required ValueChanged<T?> onChanged,
    T? value,
    String? Function(T value)? itemSubtitle,
    Iterable<String> Function(T value)? searchTerms,
    String? hintText,
    String? emptyMessage,
    String? Function(T? value)? validator,
    T Function(String query)? customValueBuilder,
    bool allowClear = false,
    bool enabled = true,
  }) : super(
          initialValue: value,
          validator: validator,
          builder: (state) {
            final field = state as _SearchableSelectionFieldState<T>;
            final selectedValue = field.value;
            final selectedLabel = selectedValue == null ? null : itemLabel(selectedValue);

            return InkWell(
              onTap: enabled
                  ? () async {
                      final result = await showModalBottomSheet<T>(
                        context: field.context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (context) => _SearchableSelectionSheet<T>(
                          options: options,
                          itemLabel: itemLabel,
                          itemSubtitle: itemSubtitle,
                          searchTerms: searchTerms,
                          hintText: hintText ?? 'Search $labelText',
                          emptyMessage: emptyMessage ?? 'No matching options',
                          customValueBuilder: customValueBuilder,
                          allowClear: allowClear,
                        ),
                      );
                      if (result != null) {
                        field.didChange(result);
                        onChanged(result);
                      }
                    }
                  : null,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: labelText,
                  hintText: hintText,
                  border: const OutlineInputBorder(),
                  errorText: field.errorText,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (allowClear && selectedValue != null)
                        IconButton(
                          tooltip: 'Clear $labelText',
                          icon: const Icon(Icons.clear),
                          onPressed: enabled
                              ? () {
                                  field.didChange(null);
                                  onChanged(null);
                                }
                              : null,
                        ),
                      const Icon(Icons.search),
                    ],
                  ),
                ),
                isEmpty: selectedLabel == null || selectedLabel.isEmpty,
                child: Text(
                  selectedLabel ?? (hintText ?? 'Select $labelText'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: selectedLabel == null
                      ? Theme.of(field.context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(field.context).hintColor,
                          )
                      : null,
                ),
              ),
            );
          },
        );

  @override
  FormFieldState<T> createState() => _SearchableSelectionFieldState<T>();
}

class _SearchableSelectionFieldState<T> extends FormFieldState<T> {
  @override
  SearchableSelectionField<T> get widget => super.widget as SearchableSelectionField<T>;

  @override
  void didUpdateWidget(covariant SearchableSelectionField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && value != widget.initialValue) {
      didChange(widget.initialValue);
    }
  }
}

class _SearchableSelectionSheet<T> extends StatefulWidget {
  final List<T> options;
  final String Function(T value) itemLabel;
  final String? Function(T value)? itemSubtitle;
  final Iterable<String> Function(T value)? searchTerms;
  final String hintText;
  final String emptyMessage;
  final T Function(String query)? customValueBuilder;
  final bool allowClear;

  const _SearchableSelectionSheet({
    required this.options,
    required this.itemLabel,
    required this.itemSubtitle,
    required this.searchTerms,
    required this.hintText,
    required this.emptyMessage,
    required this.customValueBuilder,
    required this.allowClear,
  });

  @override
  State<_SearchableSelectionSheet<T>> createState() => _SearchableSelectionSheetState<T>();
}

class _SearchableSelectionSheetState<T> extends State<_SearchableSelectionSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(T item, String query) {
    if (query.isEmpty) return true;
    final subtitle = widget.itemSubtitle?.call(item);
    final searchable = <String>[
      widget.itemLabel(item),
      if (subtitle != null) subtitle,
      ...?widget.searchTerms?.call(item),
    ].join(' ').toLowerCase();
    return searchable.contains(query.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final filteredOptions = widget.options.where((item) => _matches(item, _query.trim())).toList();
    final canUseCustomValue = widget.customValueBuilder != null && _query.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: widget.hintText,
                  border: const OutlineInputBorder(),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            if (canUseCustomValue)
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: Text('Use "${_query.trim()}"'),
                subtitle: const Text('Add a custom value'),
                onTap: () => Navigator.of(context).pop(widget.customValueBuilder!(_query.trim())),
              ),
            const Divider(height: 1),
            Expanded(
              child: filteredOptions.isEmpty
                  ? Center(child: Text(widget.emptyMessage))
                  : ListView.separated(
                      itemCount: filteredOptions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final option = filteredOptions[index];
                        final subtitle = widget.itemSubtitle?.call(option);
                        return ListTile(
                          title: Text(widget.itemLabel(option)),
                          subtitle: subtitle == null || subtitle.isEmpty ? null : Text(subtitle),
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
