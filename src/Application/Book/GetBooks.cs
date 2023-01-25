using Assessment.Application.Queries;
using MediatR;
using Assessment.Application.Common.Models;
using Microsoft.Extensions.Logging;

namespace Assessment.Application.Book
{
    public static class GetBooks
    {
        public class Command : IRequest<List<GetBooksResponse>>
        {
            public string SortBy { get; set; }
            public bool UseSp { get; set; }
        }

        public class CommandHandler : IRequestHandler<Command, List<GetBooksResponse>>
        {
            private readonly IMediator _mediator;
            private readonly ILogger<CommandHandler> _logger;

            public CommandHandler(IMediator mediator, ILogger<CommandHandler> logger)
            {
                _mediator = mediator;
                _logger = logger;
            }

            public async Task<List<GetBooksResponse>> Handle(Command request, CancellationToken cancellationToken)
            {
                List<GetBooksResponse> result = new List<GetBooksResponse>();

                //make db call
                List<Entities.Book> fullBookList;
                if (request.UseSp)
                {
                    fullBookList = await _mediator.Send(new GetBooksUsingSp.Command { SortBy = request.SortBy });
                }
                else
                {
                    fullBookList = await _mediator.Send(new GetBooksQuery.Command { SortBy = request.SortBy });
                }

                foreach(var book in fullBookList)
                {
                    result.Add(new GetBooksResponse {
                        Publisher = book.Publisher,
                        Title = book.Title,
                        AuthorFirstName = book.AuthorFirstName,
                        AuthorLastName = book.AuthorLastName,
                        Price = book.Price,
                        ModernLanguageAssociation = GetMLA(book),
                        ChicagoManualOfStyle = GetChicago(book)
                    });
                }
                

                return result;
            }
            public string GetMLA(Entities.Book book)
            {
                string result = book.AuthorLastName + ", " + book.AuthorFirstName + ".";
                result = result + "\"" + book.Title + "\"";
                if (!string.IsNullOrEmpty(book.Container))
                {
                    result = result + book.Container + ",";
                }
                
                result = result + book.Publisher + ",";

                if (!string.IsNullOrEmpty(book.PublicationDate))
                {
                    result = result + book.PublicationDate + ",";
                }
                if (!string.IsNullOrEmpty(book.Location))
                {
                    result = result + "pp. " + book.Location + ".";
                }
                

                return result;
            }

            public string GetChicago(Entities.Book book)
            {
                string result = book.AuthorLastName + ", " + book.AuthorFirstName + ".";
                result = result + "\"" + book.Title + "\"";
                if (!string.IsNullOrEmpty(book.Container))
                {
                    result = result + book.Container + ",";
                }
                if (!string.IsNullOrEmpty(book.VolumeNo))
                {
                    result = result + book.VolumeNo;
                }
                if (!string.IsNullOrEmpty(book.IssueNo))
                {
                    result = result + "(" + book.IssueNo + "): ";
                }
                if (!string.IsNullOrEmpty(book.Location))
                {
                    result = result + book.Location + ".";
                }
                if (!string.IsNullOrEmpty(book.Url))
                {
                    result = result + book.Url + ".";
                }
                

                return result;
            }
        }

        
    }
}
