import "package:app/widgets/sliver_layout_builder.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:meta/meta.dart";

class CustomSliverGrid extends StatelessWidget {
  const CustomSliverGrid({
    @required this.builder,
    @required this.cellCount,
    @required this.cellWidth,
    this.rowSpacing,
    this.columnSpacing,
  });

  /// Builder for each cell
  final IndexedWidgetBuilder builder;

  /// The number of cells in this grid
  final int cellCount;

  /// The preferred size for each cell
  final double cellWidth;

  final double rowSpacing;

  final double columnSpacing;

  EdgeInsets _rowEdgeInsets(int row) {
    if (row == 0 || rowSpacing == null) {
      return null;
    }
    return new EdgeInsets.only(top: rowSpacing);
  }

  EdgeInsets _columnEdgeInsets(int column) {
    if (column == 0 || columnSpacing == null) {
      return null;
    }
    return new EdgeInsets.only(left: columnSpacing);
  }

  Widget _builder(BuildContext context, SliverConstraints constraints) {
    // Calculate info required to build the grid
    final maxWidth = constraints.crossAxisExtent;
    final columnCount = maxWidth ~/ cellWidth;
    final rowCount = (cellCount / columnCount).ceil();
    final width = maxWidth - (columnCount - 1) * (columnSpacing ?? 0.0);

    // The custom grid is composed of a list of rows
    return new SliverList(
      delegate: new SliverChildBuilderDelegate(
        (BuildContext context, int row) {
          final children = new List<Widget>(
            // Calculate the number of cells in this row
            row == rowCount - 1 && cellCount % columnCount != 0
                ? cellCount % columnCount
                : columnCount,
          );

          // Populate the children for this row
          for (var column = 0; column < children.length; column++) {
            children[column] = new Container(
              margin: _columnEdgeInsets(column),
              width: width / columnCount,
              child: builder(context, row * columnCount + column),
            );
          }

          final insets = _rowEdgeInsets(row);
          final r = new Row(
            children: children,
            crossAxisAlignment: CrossAxisAlignment.start,
          );
          return insets != null ? new Padding(padding: insets, child: r) : r;
        },
        childCount: rowCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new SliverLayoutBuilder(builder: _builder);
  }
}
