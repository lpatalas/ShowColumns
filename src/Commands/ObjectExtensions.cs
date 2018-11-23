using System.Management.Automation;

namespace ShowColumns.Commands
{
    internal static class ObjectExtensions
    {
        public static object UnwrapPSObject(this object input)
            => input is PSObject psObject
                ? psObject.BaseObject
                : input;
    }
}
