using System.Management.Automation;

namespace ShowColumns.Commands
{
    [Cmdlet(VerbsCommon.Show, "Columns")]
    public class ShowColumnsCmdlet : PSCmdlet
    {
        private PropertyAccessor groupByPropertyAccessor;
        private TextStyleSelector groupHeaderStyleSelector;
        private TextStyleSelector itemStyleSelector;
        private ColumnItemGroupPresenter itemGroupPresenter;
        private PropertyAccessor itemNamePropertyAccessor;

        [Parameter(Mandatory = true, ValueFromPipeline = true)]
        public PSObject InputObject { get; set; }

        [Parameter(Position = 1)]
        public object GroupBy { get; set; }

        [Parameter(Mandatory = true, Position = 0)]
        public object Property { get; set; }

        [Parameter]
        public object GroupHeaderStyle { get; set; }

        [Parameter]
        public object ItemStyle { get; set; }

        [Parameter]
        [ValidateRange(1, int.MaxValue)]
        public int MinimumColumnCount { get; set; } = 1;

        protected override void BeginProcessing()
        {
            groupByPropertyAccessor
                = GroupBy != null
                ? PropertyAccessorFactory.Create(GroupBy, nameof(GroupBy))
                : _ => NoGroup.Instance;

            groupHeaderStyleSelector = TextStyleSelectorFactory.Create(GroupHeaderStyle);
            itemStyleSelector = TextStyleSelectorFactory.Create(ItemStyle);
            itemNamePropertyAccessor = PropertyAccessorFactory.Create(Property, nameof(Property));

            itemGroupPresenter = new ColumnItemGroupPresenter(
                Host,
                groupHeaderStyleSelector,
                MinimumColumnCount,
                new LineWriter(this));
        }

        protected override void ProcessRecord()
        {
            var item = new ColumnItem(
                group: groupByPropertyAccessor(InputObject),
                name: itemNamePropertyAccessor(InputObject)?.ToString(),
                style: itemStyleSelector(InputObject));

            itemGroupPresenter.Add(item);
        }

        protected override void EndProcessing()
        {
            itemGroupPresenter.Flush();
        }
    }
}
