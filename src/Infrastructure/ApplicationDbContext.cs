using Assessment.Application.Entities;
using Assessment.Application.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Diagnostics;
using System.Reflection;

namespace Assessment.Infrastructure
{
    public class ApplicationDbContext : DbContext, IApplicationDbContext
    {
        //private readonly ICurrentUserService _currentUserService;
        //private readonly IDateTime _dateTime;

        //public ApplicationDbContext(DbContextOptions options, ICurrentUserService currentUserService, IDateTime dateTime) : base(options)
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
            //_currentUserService = currentUserService;
            //_dateTime = dateTime;
        }

        public DbSet<Book> Books { get; set; }
        

        //public DbSet<CustomerUpdateRequest> CustomerUpdateRequests { get; set; }
        //public DbSet<CustomerUpdateJob> CustomerUpdateJobs { get; set; }
        //public DbSet<ConfigurationEntry> ConfigurationEntries { get; set; }
        //public DbSet<BaseObjectChangeEvent> BaseObjectChangeEvents { get; set; }
        //public DbSet<CustomerEventJobRequest> ProcessCustomerEventJobRequests { get; set; }

        public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = new CancellationToken())
        {
            //foreach (var entry in ChangeTracker.Entries<AuditableEntity>())
            //{
            //    switch (entry.State)
            //    {
            //        case EntityState.Added:
            //            entry.Entity.CreatedBy = _currentUserService.UserId;
            //            entry.Entity.Created = _dateTime.UtcNow;
            //            entry.Entity.LastModified = _dateTime.UtcNow;
            //            break;
            //        case EntityState.Modified:
            //            entry.Entity.LastModifiedBy = _currentUserService.UserId;
            //            entry.Entity.LastModified = _dateTime.UtcNow;
            //            break;
            //    }
            //}
            

            return base.SaveChangesAsync(cancellationToken);
        }

        protected override void OnModelCreating(ModelBuilder builder)
        {

            builder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

            base.OnModelCreating(builder);
        }

        
    //    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    //=> optionsBuilder.LogTo(message => Debug.WriteLine(message));

    }
}
