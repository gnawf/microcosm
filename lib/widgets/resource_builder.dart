import "package:app/resource/resource.dart";
import "package:flutter/material.dart";

typedef WidgetBuilderWithData<ResourceType> = Widget Function(BuildContext context, ResourceType resource);

class ResourceBuilder<ResourceType extends Resource<DataType>, DataType> extends StatelessWidget {
  const ResourceBuilder({
    Key key,
    @required this.resource,
    @required this.doneBuilder,
    this.placeholderBuilder = _placeholder,
    this.loadingBuilder = _loading,
    this.errorBuilder = _error,
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

  static Widget _placeholder(BuildContext context) => const SizedBox.shrink();

  static Widget _loading(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  static Widget _error(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Text("$error"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (resource.state) {
      case ResourceState.placeholder:
        return placeholderBuilder(context);
      case ResourceState.loading:
        return loadingBuilder(context);
      case ResourceState.done:
        return doneBuilder(context, resource);
      case ResourceState.error:
        return errorBuilder(context, resource);
    }

    throw UnsupportedError("Switch was not exhaustive");
  }
}
