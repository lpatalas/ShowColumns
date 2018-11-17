using System.Management.Automation;

namespace FormatColumns
{
	[Cmdlet("Format", "Columns")]
	public class FormatColumnsCmdlet : Cmdlet
	{
		[Parameter(ValueFromPipeline = true)]
		public PSObject InputObject { get; set; }

		protected override void BeginProcessing()
		{
			WriteObject("Test");
		}
	}
}
