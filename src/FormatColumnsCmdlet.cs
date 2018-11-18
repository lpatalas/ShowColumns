using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

namespace FormatColumns
{
	[Cmdlet("Format", "Columns")]
	public class FormatColumnsCmdlet : Cmdlet
	{
        private PropertyAccessor groupByPropertyAccessor;
        private PropertyAccessor itemNamePropertyAccessor;

        private readonly List<ColumnItem> currentGroupItems = new List<ColumnItem>();
        private object currentGroup;

		[Parameter(Mandatory = true, ValueFromPipeline = true)]
		public PSObject InputObject { get; set; }

        [Parameter(Mandatory = true)]
        public object GroupBy { get; set; }

		[Parameter(Mandatory = true)]
		public object Property { get; set; }

        protected override void BeginProcessing()
        {
            groupByPropertyAccessor = new PropertyAccessor(GroupBy, nameof(GroupBy));
            itemNamePropertyAccessor = new PropertyAccessor(Property, nameof(Property));
        }

        protected override void ProcessRecord()
		{
            var groupName = groupByPropertyAccessor.Invoke(InputObject);
            var itemName = itemNamePropertyAccessor.Invoke(InputObject);
            var item = new ColumnItem(groupName, itemName);

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

        protected override void EndProcessing()
        {
            FlushCurrentGroup();
        }

        private void FlushCurrentGroup()
        {
            if (currentGroupItems.Any())
            {
                WriteObject($"=== Group {currentGroup} ===");
                foreach (var groupItem in currentGroupItems)
                    WriteObject(groupItem.ToString());

                currentGroupItems.Clear();
            }
        }
    }
}
