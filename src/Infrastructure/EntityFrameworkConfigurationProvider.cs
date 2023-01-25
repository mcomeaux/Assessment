using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;


namespace Assessment.Infrastructure
{
    public class EntityFrameworkConfigurationProvider : ConfigurationProvider
    {
        public Action<DbContextOptionsBuilder> OptionsAction { get; }

        public EntityFrameworkConfigurationProvider(Action<DbContextOptionsBuilder> optionsAction)
        {
            OptionsAction = optionsAction;
        }

        public override void Load()
        {
            var builder = new DbContextOptionsBuilder<ApplicationDbContext>();

            OptionsAction(builder);

            //using (var dbContext = new ApplicationDbContext(builder.Options)) //, new UnknownCurrentUserService(), new DateTimeService()))
            //{
            //    Data = dbContext.ConfigurationEntries.Any()
            //        ? dbContext.ConfigurationEntries.ToDictionary(c => c.Key, c => c.Value)
            //        : new Dictionary<string, string>();
            //}
        }

    }
}
