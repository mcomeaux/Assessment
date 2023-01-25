using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Assessment.Application.Common.Models
{
    public class GetBooksResponse
    {
        public string Publisher { get; set; }
        public string Title { get; set; }
        public string AuthorLastName { get; set; }
        public string AuthorFirstName { get; set; }
        public decimal Price { get; set; }
        public string ModernLanguageAssociation { get; set; }
        public string ChicagoManualOfStyle { get; set; }
    }
}
