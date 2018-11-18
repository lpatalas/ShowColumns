using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace ShowColumns
{
    internal delegate object PropertyAccessor(PSObject inputObject);

    internal static class PropertyAccessorFactory
    {
        public static PropertyAccessor Create(object propertyNameOrScriptBlock, string parameterName)
        {
            if (propertyNameOrScriptBlock is string propertyName)
                return CreateByNamePropertyAccessor(propertyName);
            else if (propertyNameOrScriptBlock is ScriptBlock scriptBlock)
                return CreateScriptBlockPropertyAccessor(scriptBlock);
            else
                throw new ApplicationException(
                    $"{parameterName} parameter must be a String or ScriptBlock"
                    + $" but found '{propertyNameOrScriptBlock?.GetType()?.FullName ?? "<null>"}'.");
        }

        private static PropertyAccessor CreateByNamePropertyAccessor(string propertyName)
            => obj
                => obj.BaseObject is IDictionary dictionary
                    ? dictionary[propertyName]
                    : obj.Properties[propertyName].Value;

        private static PropertyAccessor CreateScriptBlockPropertyAccessor(ScriptBlock scriptBlock)
            => obj
                => scriptBlock.InvokeWithContext(
                    functionsToDefine: null,
                    variablesToDefine: new List<PSVariable>(1) { new PSVariable("_", obj) })
                    ?.FirstOrDefault();
    }
}
