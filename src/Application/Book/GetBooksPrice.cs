using Assessment.Application.Queries;
using MediatR;
using Assessment.Application.Common.Models;
using Microsoft.Extensions.Logging;

namespace Assessment.Application.Book
{
    public class GetBooksPrice
    {
        public class Command : IRequest<GetBooksPriceResponse>
        {
        }

        public class CommandHandler : IRequestHandler<Command, GetBooksPriceResponse>
        {
            private readonly IMediator _mediator;
            private readonly ILogger<CommandHandler> _logger;
            //TODO: add securiti config and pull page size

            public CommandHandler(IMediator mediator, ILogger<CommandHandler> logger)
            {
                _mediator = mediator;
                _logger = logger;
            }

            public async Task<GetBooksPriceResponse> Handle(Command request, CancellationToken cancellationToken)
            {
                GetBooksPriceResponse result = new GetBooksPriceResponse();

                //make db call
                var total = await _mediator.Send(new GetBooksPriceTotalQuery.Command());

                result.TotalPrice = total;
                //map fields

                return result;
            }
        }
    }
}
