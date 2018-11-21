using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace ShowColumns
{
    internal static class ScriptBlockExtensions
    {
        public static PSObject InvokeWithInputObject(
            this ScriptBlock scriptBlock,
            object inputObject)
        {
            var variables = new List<PSVariable>(1)
            {
                new PSVariable("_", inputObject)
            };

            var results = scriptBlock.InvokeWithContext(
                functionsToDefine: null,
                variablesToDefine: variables);

            return results?.FirstOrDefault();
        }
    }
}
