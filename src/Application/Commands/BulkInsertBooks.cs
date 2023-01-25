using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Assessment.Application.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Commands
{
    public class BulkInsertBooks
    {
        public class Command : IRequest<int>
        {
            public List<Assessment.Application.Entities.Book> books { get; set; }
        }

        public class CommandHandler : IRequestHandler<Command, int>
        {
            private readonly IApplicationDbContext _dbContext;


            public CommandHandler(IApplicationDbContext dbContext)
            {
                _dbContext = dbContext;
            }

            public async Task<int> Handle(Command request, CancellationToken cancellationToken)
            {
                await _dbContext.Books.AddRangeAsync(request.books.ToArray());

                var result = await _dbContext.SaveChangesAsync(cancellationToken);


                return result;
            }
        }
    }
}
