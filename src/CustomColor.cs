using System;
using System.Collections;
using System.Management.Automation;

namespace ShowColumns
{
    public struct CustomColor
    {
        public ConsoleColor Foreground { get; }
        public ConsoleColor Background { get; }

        public static readonly CustomColor Default
            = new CustomColor(ConsoleColor.Gray, ConsoleColor.Black);

        public CustomColor(ConsoleColor foregroundColor)
        {
            this.Foreground = foregroundColor;
            this.Background = ConsoleColor.Black;
        }

        public CustomColor(ConsoleColor foregroundColor, ConsoleColor backgroundColor)
        {
            this.Foreground = foregroundColor;
            this.Background = backgroundColor;
        }

        public CustomColor(IDictionary dictionary)
        {
            this.Foreground = TryConvertToConsoleColor(
                dictionary.GetValueOrDefault("Foreground"),
                ConsoleColor.Gray);

            this.Background = TryConvertToConsoleColor(
                dictionary.GetValueOrDefault("Background"),
                ConsoleColor.Black);
        }

        public CustomColor(string foregroundColorName)
        {
            this.Foreground = TryConvertToConsoleColor(foregroundColorName, ConsoleColor.Gray);
            this.Background = ConsoleColor.Black;
        }

        public static CustomColor FromPSObject(PSObject inputObject)
        {
            if (inputObject?.BaseObject != null)
            {
                if (inputObject.BaseObject is ConsoleColor foregroundColor)
                    return new CustomColor(foregroundColor);
                else if (inputObject.BaseObject is string foregroundColorName)
                    return new CustomColor(foregroundColorName);
                else if (inputObject.BaseObject is IDictionary dictionary)
                    return new CustomColor(dictionary);
            }

            return CustomColor.Default;
        }

        private static ConsoleColor TryConvertToConsoleColor(object value, ConsoleColor defaultColor)
        {
            if (value is ConsoleColor consoleColor)
            {
                return consoleColor;
            }
            else if (value is string colorString
                && Enum.TryParse<ConsoleColor>(colorString, out var parsedConsoleColor))
            {
                return parsedConsoleColor;
            }
            else
            {
                return defaultColor;
            }
        }
    }
}
