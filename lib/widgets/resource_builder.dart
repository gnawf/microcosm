import "package:app/resource/resource.dart";
import "package:flutter/material.dart";

typedef WidgetBuilderWithData<Data> = Widget Function(BuildContext context, Data data);

typedef EmptyPredicate<Data> = bool Function(Data data);

class ResourceBuilder<ResourceType extends Resource<DataType>, DataType> extends StatelessWidget {
  const ResourceBuilder({
    Key key,
    @required this.resource,
    @required this.doneBuilder,
    this.placeholderBuilder = _placeholderBuilder,
    this.loadingBuilder = _loadingBuilder,
    this.errorBuilder = _errorBuilder,
    this.emptyBuilder = _emptyBuilder,
    this.emptyPredicate = _emptyPredicate,
  })  : assert(resource != null),
        assert(doneBuilder != null),
        assert(placeholderBuilder != null),
        assert(loadingBuilder != null),
        assert(errorBuilder != null),
        super(key: key);

  final ResourceType resource;

  final WidgetBuilder placeholderBuilder;

  final WidgetBuilder loadingBuilder;

  final WidgetBuilderWithData<ResourceType> doneBuilder;

  final WidgetBuilderWithData<ResourceType> errorBuilder;

  final WidgetBuilderWithData<ResourceType> emptyBuilder;

  final EmptyPredicate<ResourceType> emptyPredicate;

  static Widget _placeholderBuilder(BuildContext context) => const SizedBox.shrink();

  static Widget _loadingBuilder(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  static Widget _errorBuilder(BuildContext context, Resource resource) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Text("${resource.error}"),
      ),
    );
  }

  static Widget _emptyBuilder(BuildContext context, Resource resource) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Text("Nothing to show"),
      ),
    );
  }

  static bool _emptyPredicate(Resource resource) {
    final data = resource.data;
    return data is List ? data.isEmpty : resource.data == null;
  }

  @override
  Widget build(BuildContext context) {
    switch (resource.state) {
      case ResourceState.placeholder:
        return placeholderBuilder(context);
      case ResourceState.loading:
        return loadingBuilder(context);
      case ResourceState.done:
        return emptyPredicate(resource) ? emptyBuilder(context, resource) : doneBuilder(context, resource);
      case ResourceState.error:
        return errorBuilder(context, resource);
    }

    throw UnsupportedError("Switch was not exhaustive");
  }
}
