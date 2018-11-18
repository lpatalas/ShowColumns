using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Host;

namespace ShowColumns
{
    internal class ColumnsPresenter
    {
        public static void WriteColumns(
            PSHost host,
            IReadOnlyList<ColumnItem> items,
            int minimumColumnCount)
        {
            var columnWidths = GetBestFittingColumnWidths(
                items,
                availableWidth: host.UI.RawUI.BufferSize.Width,
                minimumColumnCount: minimumColumnCount);
            var columnCount = columnWidths.Count;
            var countPerColumn = GetItemCountPerColumn(items.Count, columnCount);

            for (var rowIndex = 0; rowIndex < countPerColumn; rowIndex++)
            {
                for (var columnIndex = 0; columnIndex < columnCount; columnIndex++)
                {
                    var itemIndex = columnIndex * countPerColumn + rowIndex;
                    var columnWidth = columnWidths[columnIndex];

                    if (itemIndex < items.Count)
                    {
                        var item = items[itemIndex];

                        if (columnIndex > 0)
                            host.UI.Write(" ");

                        var displayedName = item.Width <= columnWidth
                            ? item.Name
                            : (item.Name.Substring(0, columnWidth - 3) + "...");

                        host.UI.Write(
                            item.Color.Foreground,
                            item.Color.Background,
                            displayedName);

                        if (columnIndex < (columnCount - 1))
                        {
                            var padding = columnWidth - displayedName.Length;
                            host.UI.Write(new string(' ', padding));
                        }
                    }
                }

                if (host.UI.RawUI.CursorPosition.X > 0)
                    host.UI.WriteLine();
            }
        }

        private static IReadOnlyList<int> GetBestFittingColumnWidths(
            IReadOnlyList<ColumnItem> items,
            int availableWidth,
            int minimumColumnCount)
        {
            for (var columnCount = items.Count; columnCount > 0; columnCount--)
            {
                var columnWidths = GetColumnWidths(items, columnCount);
                var totalWidth = columnWidths.Sum() + (columnWidths.Count - 1);

                if (totalWidth <= availableWidth)
                {
                    return columnWidths;
                }
                else if (columnCount == minimumColumnCount)
                {
                    var totalSpaces = columnCount - 1;
                    var columnWidth = (availableWidth - totalSpaces) / columnCount;
                    return Enumerable.Repeat(columnWidth, columnCount).ToList();
                }
            }

            return new List<int>(1) { availableWidth };
        }

        private static IReadOnlyList<int> GetColumnWidths(
            IReadOnlyList<ColumnItem> items,
            int columnCount)
        {
            var countPerColumn = GetItemCountPerColumn(items.Count, columnCount);
            var columnWidths = new int[columnCount];

            for (var index = 0; index < items.Count; index++)
            {
                var columnIndex = index / countPerColumn;
                if (columnWidths[columnIndex] < items[index].Width)
                    columnWidths[columnIndex] = items[index].Width;
            }

            return columnWidths;
        }

        private static int GetItemCountPerColumn(int totalItemCount, int columnCount)
        {
            return (totalItemCount + columnCount - 1) / columnCount;
        }
    }
}
