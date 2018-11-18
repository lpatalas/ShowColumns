using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace FormatColumns
{
    internal class PropertyAccessor
    {
        private readonly Func<PSObject, object> propertyAccessor;

        public PropertyAccessor(object propertyNameOrScriptBlock, string parameterName)
        {
            if (propertyNameOrScriptBlock is string propertyName)
                propertyAccessor = CreateByNamePropertyAccessor(propertyName);
            else if (propertyNameOrScriptBlock is ScriptBlock scriptBlock)
                propertyAccessor = CreateScriptBlockPropertyAccessor(scriptBlock);
            else
                throw new ApplicationException(
                    $"{parameterName} parameter must be a String or ScriptBlock"
                    + $" but found '{propertyNameOrScriptBlock?.GetType()?.FullName ?? "<null>"}'.");
        }

        public object Invoke(PSObject input)
            => propertyAccessor(input);

        private Func<PSObject, object> CreateByNamePropertyAccessor(string propertyName)
            => obj
                => obj.BaseObject is IDictionary dictionary
                    ? dictionary[propertyName]
                    : obj.Properties[propertyName];

        private Func<PSObject, object> CreateScriptBlockPropertyAccessor(ScriptBlock scriptBlock)
            => obj
                => scriptBlock.InvokeWithContext(
                    functionsToDefine: null,
                    variablesToDefine: new List<PSVariable>(1) { new PSVariable("_", obj) })
                    ?.FirstOrDefault();
    }
}
