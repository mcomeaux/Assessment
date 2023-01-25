using App.Metrics.AspNetCore;
using Autofac.Extensions.DependencyInjection;
using Assessment.Infrastructure;
using Microsoft.EntityFrameworkCore;
using NLog;
using NLog.Web;

namespace Assessment.Api
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var logger = NLogBuilder.ConfigureNLog("nlog.config").GetCurrentClassLogger();

            try
            {
                logger.Debug("Initialize main");

                var host = CreateHostBuilder(args).Build();

                //var l = host.Services.GetRequiredService<ILogger<LogEverythingAttribute>>();
                //GlobalJobFilters.Filters.Add(new LogEverythingAttribute(l));

                host.Run();
            }
            catch (Exception exception)
            {
                //NLog: catch setup errors
                logger.Error(exception, "Stopped program because of exception");
                throw;
            }
            finally
            {
                // Ensure to flush and stop internal timers/threads before application-exit (Avoid segmentation fault on Linux)
                LogManager.Shutdown();
            }
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .UseMetrics()
                .UseServiceProviderFactory(new AutofacServiceProviderFactory())
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                })
                .ConfigureAppConfiguration((ctx, builder) =>
                {
                    var config = builder.Build();
                    builder.AddEfConfiguration(o =>
                    {
                        o.UseSqlServer(config.GetConnectionString("DefaultConnection"),
                            sqlServerOptionsAction: sqlOptions =>
                            {
                                sqlOptions.EnableRetryOnFailure();
                            });
                    });
                })
                .ConfigureLogging(logging =>
                {
                    logging.ClearProviders();
                    logging.SetMinimumLevel(Microsoft.Extensions.Logging.LogLevel.Trace);
                })
                .UseNLog();
    }
}
