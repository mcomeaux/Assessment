using Assessment.Application.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Newtonsoft.Json;
using Microsoft.Extensions.Logging;
using NLog.Extensions.Logging;
using Assessment.Application.Common.Interfaces;
using Assessment.Infrastructure.Services;

namespace Assessment.Infrastructure
{
    public static class DependencyInjection
    {
        //public static readonly ILoggerFactory MyLoggerFactory = new LoggerFactory(new[] { new NLogLoggerProvider() });

        public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration, IHostEnvironment environment)
        {

            JsonConvert.DefaultSettings = () => new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore
            };

            services.AddDbContext<ApplicationDbContext>(options =>
            {
                options
                    .UseSqlServer(configuration.GetConnectionString("DefaultConnection"))
                    .EnableSensitiveDataLogging(true);
                //.UseLoggerFactory(MyLoggerFactory);
                //.UseQueryTrackingBehavior(QueryTrackingBehavior.);
            });

            services.AddScoped<IApplicationDbContext>(provider => provider.GetRequiredService<ApplicationDbContext>());
            //services.AddTransient<IApplicationDbContext>(provider => provider.GetRequiredService<ApplicationDbContext>());


            services.AddTransient<IDateTime, DateTimeService>();


            return services;
        }
    }
}
