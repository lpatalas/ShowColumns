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
		private Func<PSObject, string> propertyAccessor;

		[Parameter(ValueFromPipeline = true)]
		public PSObject InputObject { get; set; }

		[Parameter]
		public object Property { get; set; }

        protected override void BeginProcessing()
        {
            if (Property is string propertyName)
                propertyAccessor = CreateByNamePropertyAccessor(propertyName);
            else if (Property is ScriptBlock scriptBlock)
                propertyAccessor = CreateScriptBlockPropertyAccessor(scriptBlock);
            else
                throw new ApplicationException(
                    $"{nameof(Property)} parameter must be a String or ScriptBlock"
                    + $" but found '{Property?.GetType()?.FullName ?? "<null>"}'.");
        }

        protected override void ProcessRecord()
		{
            var value = propertyAccessor(InputObject);
			WriteObject($"Script: {value}");
		}

        private Func<PSObject, string> CreateByNamePropertyAccessor(string propertyName)
            => obj
                => obj.BaseObject is IDictionary dictionary
                    ? dictionary[propertyName]?.ToString()
                    : obj.Properties[propertyName]?.ToString();

        private Func<PSObject, string> CreateScriptBlockPropertyAccessor(ScriptBlock scriptBlock)
            => obj
                => scriptBlock.InvokeWithContext(
                    functionsToDefine: null,
                    variablesToDefine: new List<PSVariable>(1) { new PSVariable("_", obj) })
                    ?.FirstOrDefault()
                    ?.ToString();

	}
}
