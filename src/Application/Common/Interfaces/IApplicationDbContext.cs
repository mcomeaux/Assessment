using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Infrastructure;

namespace Assessment.Application.Interfaces
{
    public interface IApplicationDbContext
    {
        public DbSet<Entities.Book> Books { get; set; }

        Task<int> SaveChangesAsync(CancellationToken cancellationToken);

        DatabaseFacade Database { get; }
        EntityEntry Entry(object entity);

    }
}
