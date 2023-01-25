using Assessment.Application.Common.Interfaces;
using System;

namespace Assessment.Infrastructure.Services
{
    public class DateTimeService : IDateTime
    {
        public DateTime UtcNow => DateTime.UtcNow;
    }
}
