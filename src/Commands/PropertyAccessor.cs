﻿using System;
using System.Collections;
using System.Management.Automation;

namespace ShowColumns.Commands
{
    internal delegate object PropertyAccessor(PSObject inputObject);

    internal static class PropertyAccessorFactory
    {
        public static readonly PropertyAccessor ToStringAccessor
            = obj => obj?.ToString() ?? string.Empty;

        public static PropertyAccessor Create(object propertyNameOrScriptBlock, string parameterName)
        {
            propertyNameOrScriptBlock = propertyNameOrScriptBlock.UnwrapPSObject();

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
                    : obj.Properties[propertyName]?.Value;

        private static PropertyAccessor CreateScriptBlockPropertyAccessor(ScriptBlock scriptBlock)
            => obj
                => scriptBlock.InvokeWithInputObject(obj);
    }
}
