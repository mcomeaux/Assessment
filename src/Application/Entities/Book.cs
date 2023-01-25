

namespace Assessment.Application.Entities
{
    public class Book
    {
        public int BookId { get; set; }
        public string Publisher { get; set; }
        public string Title { get; set; }
        public string? Container { get; set; }
        public string? PublicationDate { get; set; }
        public string? Location { get; set; }
        public string? IssueNo { get; set; }
        public string? VolumeNo { get; set; }
        public string? Url { get; set; }
        public string AuthorLastName { get; set; }
        public string AuthorFirstName { get; set; }
        public decimal Price { get; set; }
    }
}
