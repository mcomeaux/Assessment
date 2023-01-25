using Microsoft.AspNetCore.Mvc;
using Assessment.Application.Common.Models;
using Assessment.Application.Book;

namespace Assessment.Api.Controllers
{
    [Route("api/Books")]
    [ApiController]
    public class BooksController : ApiController
    {
        
        [HttpGet]
        [ProducesResponseType(200)]
        [ProducesResponseType(400)]
        [Route("sortP")]
        public async Task<ActionResult<GetBooksResponse>> GetBooksSortP() =>
            Accepted(await Mediator.Send(new GetBooks.Command { SortBy = "pub", UseSp = false }));

        [HttpGet]
        [ProducesResponseType(200)]
        [ProducesResponseType(400)]
        [Route("sortA")]
        public async Task<ActionResult<GetBooksResponse>> GetBooksSortA() =>
            Accepted(await Mediator.Send(new GetBooks.Command { SortBy = "author", UseSp = false }));

        [HttpGet]
        [ProducesResponseType(200)]
        [ProducesResponseType(400)]
        [Route("sortP/useSp")]
        public async Task<ActionResult<GetBooksResponse>> GetBooksSortPUseSp() =>
            Accepted(await Mediator.Send(new GetBooks.Command { SortBy = "pub", UseSp = true }));

        [HttpGet]
        [ProducesResponseType(200)]
        [ProducesResponseType(400)]
        [Route("sortA/USeSp")]
        public async Task<ActionResult<GetBooksResponse>> GetBooksSortAUseSp() =>
            Accepted(await Mediator.Send(new GetBooks.Command { SortBy = "author", UseSp = true }));

        [HttpGet]
        [ProducesResponseType(200)]
        [ProducesResponseType(400)]
        [Route("price")]
        public async Task<ActionResult<GetBooksResponse>> GetBooksPrice() =>
            Accepted(await Mediator.Send(new GetBooksPrice.Command()));
    }
}
