using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace ShowColumns
{
    [Cmdlet(VerbsCommon.Show, "Columns")]
    public class ShowColumnsCmdlet : PSCmdlet
    {
        private PropertyAccessor groupByPropertyAccessor;
        private PropertyAccessor itemNamePropertyAccessor;

        private readonly List<ColumnItem> currentGroupItems = new List<ColumnItem>();
        private object currentGroup;

        [Parameter(Mandatory = true, ValueFromPipeline = true)]
        public PSObject InputObject { get; set; }

        [Parameter]
        public object GroupBy { get; set; }

        [Parameter(Mandatory = true)]
        public object Property { get; set; }

        [Parameter]
        public ConsoleColor GroupColor { get; set; } = ConsoleColor.DarkGray;

        [Parameter]
        public ScriptBlock ItemColors { get; set; }

        [Parameter]
        [ValidateRange(1, int.MaxValue)]
        public int MinimumColumnCount { get; set; } = 1;

        protected override void BeginProcessing()
        {
            groupByPropertyAccessor
                = GroupBy != null
                ? PropertyAccessorFactory.Create(GroupBy, nameof(GroupBy))
                : _ => NoGroup.Instance;

            itemNamePropertyAccessor = PropertyAccessorFactory.Create(Property, nameof(Property));
        }

        protected override void ProcessRecord()
        {
            var color = GetItemColor(InputObject);
            var groupName = groupByPropertyAccessor.Invoke(InputObject);
            var itemName = itemNamePropertyAccessor.Invoke(InputObject);
            var item = new ColumnItem(color, groupName, itemName?.ToString());

            if (object.Equals(currentGroup, item.Group))
            {
                currentGroupItems.Add(item);
            }
            else
            {
                FlushCurrentGroup();
                currentGroup = item.Group;
                currentGroupItems.Add(item);
            }
        }

        private ConsoleColor GetItemColor(PSObject inputObject)
        {
            if (ItemColors != null)
            {
                var results = ItemColors.InvokeWithContext(
                    functionsToDefine: null,
                    variablesToDefine: new List<PSVariable>(1) { new PSVariable("_", inputObject) });
                var firstResult = results?.FirstOrDefault();

                if (firstResult.BaseObject is ConsoleColor consoleColor)
                {
                    return consoleColor;
                }
                else if (firstResult.BaseObject is string colorString
                    && Enum.TryParse<ConsoleColor>(colorString, out var parsedConsoleColor))
                {
                    return parsedConsoleColor;
                }
            }

            return ConsoleColor.Gray;
        }

        protected override void EndProcessing()
        {
            FlushCurrentGroup();
        }

        private void FlushCurrentGroup()
        {
            if (currentGroupItems.Any())
            {
                if (currentGroup != NoGroup.Instance)
                    Host.UI.WriteLine(GroupColor, ConsoleColor.Black, currentGroup.ToString());

                ColumnsPresenter.WriteColumns(
                    Host,
                    currentGroupItems,
                    MinimumColumnCount);

                currentGroupItems.Clear();
            }
        }


    }
}
