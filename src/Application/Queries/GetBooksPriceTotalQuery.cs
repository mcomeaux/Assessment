using MediatR;
using Assessment.Application.Interfaces;

namespace Assessment.Application.Queries
{
    public class GetBooksPriceTotalQuery
    {
        public class Command : IRequest<decimal>
        {
        }

        public class CommandHandler : IRequestHandler<Command, decimal>
        {
            private readonly IApplicationDbContext _dbContext;


            public CommandHandler(IApplicationDbContext dbContext)
            {
                _dbContext = dbContext;
            }

            public async Task<decimal> Handle(Command request, CancellationToken cancellationToken)
            {
                var result = _dbContext.Books.Sum(s => s.Price);


                return result;
            }
        }
    }
}
