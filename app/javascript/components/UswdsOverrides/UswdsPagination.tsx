/* eslint-disable id-length, complexity, no-plusplus, max-statements, no-undef */
/* Above eslint rules are disabled as this file which is from USWDS library - https://github.com/trussworks/react-uswds/blob/main/src/components/Pagination/Pagination.tsx is being overriden so disabled few rules so as we can override the needed behaviour without much changes */

import React, { useContext } from 'react';
import classnames from 'classnames';
import { Icon, Link, Button } from '@trussworks/react-uswds';

import { getUriWithParam } from '../../utils';
import { LanguageContext } from '../../contexts/LanguageContext'

type PaginationProps = {
  pathname: string // pathname of results page
  totalPages: number // total items divided by items per page
  currentPage: number // current page number (starting at 1)
  maxSlots?: number // number of pagination "slots"
  unboundedResults: boolean
  onClickNext?: () => void
  onClickPrevious?: () => void
  onClickPageNumber?: (
    event: React.MouseEvent<HTMLButtonElement>,
    page: number
  ) => void
}

const PaginationPage = ({
  page,
  isCurrent,
  onClickPageNumber
}: {
  page: number
  isCurrent?: boolean
  onClickPageNumber?: (
    event: React.MouseEvent<HTMLButtonElement>,
    page: number
  ) => void
}) => {
  const linkClasses = classnames('usa-pagination__button', {
    'usa-current': isCurrent
  });

  return (
    <li
      key={`pagination_page_${page}`}
      className="usa-pagination__item usa-pagination__page-no">
      {onClickPageNumber ? (
        <Button
          type="button"
          unstyled
          data-testid="pagination-page-number"
          className={linkClasses}
          aria-label={`Page ${page}`}
          aria-current={isCurrent ? 'page' : undefined}
          onClick={(event) => {
            onClickPageNumber(event, page);
          }}>
          {page}
        </Button>
      ) : (
        <Link
          href={getUriWithParam(window.location.href, 'page', page.toString())}  
          className={linkClasses}
          aria-label={`Page ${page}`}
          aria-current={isCurrent ? 'page' : undefined}>
          {page}
        </Link>
      )}
    </li>
  );
};

const PaginationOverflow = () => (
  <li
    className="usa-pagination__item usa-pagination__overflow"
    role="presentation">
    <span>…</span>
  </li>
);

export const UswdsPagination = ({
  totalPages,
  currentPage,
  className,
  maxSlots = 7,
  unboundedResults,
  onClickPrevious,
  onClickNext,
  onClickPageNumber,
  ...props
}: PaginationProps & JSX.IntrinsicElements['nav']): React.ReactElement => {
  const i18n = useContext(LanguageContext);

  const navClasses = classnames('usa-pagination', className);

  const isOnFirstPage = currentPage === 1;
  const isOnLastPage = currentPage === totalPages;

  const showOverflow = totalPages > maxSlots; // If more pages than slots, use overflow indicator(s)

  const middleSlot = Math.round(maxSlots / 2); // 4 if maxSlots is 7
  let showPrevOverflow; 
  if (!unboundedResults) {
    showPrevOverflow = showOverflow && currentPage > middleSlot;
  } else {
    showPrevOverflow = showOverflow && currentPage > (middleSlot + 2);
  }
  
  const showNextOverflow =
    showOverflow && totalPages - currentPage >= middleSlot;

  // Assemble array of page numbers to be shown
  const currentPageRange: Array<number | 'overflow'> = showOverflow
    ? [currentPage]
    : Array.from({ length: totalPages }).map((_, i) => i + 1);

  if (showOverflow) {
    // Determine range of pages to show based on current page & number of slots
    // Follows logic described at: https://designsystem.digital.gov/components/pagination/
    const prevSlots = isOnFirstPage ? 0 : showPrevOverflow ? 2 : 1; // first page + prev overflow
    const nextSlots = isOnLastPage ? 0 : showNextOverflow ? 2 : 1; // next overflow + last page
    const pageRangeSize = maxSlots - 1 - (prevSlots + nextSlots); // remaining slots to show (minus one for the current page)

    // Determine how many slots we have before/after the current page
    let currentPageBeforeSize = 0;
    let currentPageAfterSize = 0;
    if (showPrevOverflow && showNextOverflow) {
      // We are in the middle of the set, there will be overflow (...) at both the beginning & end
      // Ex: [1] [...] [9] [10] [11] [...] [24]
      currentPageBeforeSize = Math.round((pageRangeSize - 1) / 2);

      if (unboundedResults) {
        currentPageBeforeSize += 2;
      }
      
      currentPageAfterSize = pageRangeSize - currentPageBeforeSize;
    } else if (showPrevOverflow) {
      // We are in the end of the set, there will be overflow (...) at the beginning
      // Ex: [1] [...] [20] [21] [22] [23] [24]
      currentPageAfterSize = totalPages - currentPage - 1; // current & last
      currentPageAfterSize = currentPageAfterSize < 0 ? 0 : currentPageAfterSize;
      currentPageBeforeSize = pageRangeSize - currentPageAfterSize;
    } else if (showNextOverflow) {
      // We are in the beginning of the set, there will be overflow (...) at the end
      // Ex: [1] [2] [3] [4] [5] [...] [24]
      currentPageBeforeSize = currentPage - 2; // first & current
      currentPageBeforeSize =
        currentPageBeforeSize < 0 ? 0 : currentPageBeforeSize;
      currentPageAfterSize = pageRangeSize - currentPageBeforeSize;
    }

    if (unboundedResults) {
      currentPageAfterSize = 0;
    }

    // Populate the remaining slots
    let counter = 1;
    while (currentPageBeforeSize > 0) {
      // Add previous pages before the current page
      currentPageRange.unshift(currentPage - counter);
      counter++;
      currentPageBeforeSize--;
    }

    counter = 1;
    while (currentPageAfterSize > 0) {
      // Add subsequent pages after the current page
      currentPageRange.push(currentPage + counter);
      counter++;
      currentPageAfterSize--;
    }

    // Add prev/next overflow indicators, and first/last pages as needed
    if (showPrevOverflow)
      currentPageRange.unshift('overflow');
    if (currentPage !== 1) 
      currentPageRange.unshift(1);
    if (showNextOverflow) 
      currentPageRange.push('overflow');
    if (currentPage !== totalPages && !unboundedResults) 
      currentPageRange.push(totalPages);
  }

  const prevPage = !isOnFirstPage && currentPage - 1;
  const nextPage = !isOnLastPage && currentPage + 1;

  return (
    <nav aria-label="Pagination" className={navClasses} {...props}>
      <ul className="usa-pagination__list">
        {prevPage && (
          <li className="usa-pagination__item usa-pagination__arrow">
            {onClickPrevious ? (
              <Button
                type="button"
                unstyled
                className="usa-pagination__link usa-pagination__previous-page"
                aria-label="Previous page"
                data-testid="pagination-previous"
                onClick={onClickPrevious}>
                <Icon.NavigateBefore />
                <span className="usa-pagination__link-text">{i18n.t("prevLabel")}</span>
              </Button>
            ) : (
              <Link
                href={getUriWithParam(window.location.href, 'page', prevPage.toString())}
                className="usa-pagination__link usa-pagination__previous-page"
                aria-label="Previous page">
                <Icon.NavigateBefore />
                <span className="usa-pagination__link-text">{i18n.t("prevLabel")}</span>
              </Link>
            )}
          </li>
        )}

        {currentPageRange.map((pageNum, i) =>
          pageNum === 'overflow' ? (
            <PaginationOverflow key={`pagination_overflow_${i}`} />
          ) : (
            <PaginationPage
              key={`pagination_page_${pageNum}`}
              page={pageNum}
              isCurrent={pageNum === currentPage}
              onClickPageNumber={onClickPageNumber}
            />
          )
        )}

        {nextPage && (
          <li className="usa-pagination__item usa-pagination__arrow">
            {onClickNext ? (
              <Button
                type="button"
                unstyled
                className="usa-pagination__link usa-pagination__next-page"
                aria-label="Next page"
                data-testid="pagination-next"
                onClick={onClickNext}>
                <span className="usa-pagination__link-text">
                  {i18n.t("nextLabel")}
                </span>
                <Icon.NavigateNext />
              </Button>
            ) : (
              <Link
                href={getUriWithParam(window.location.href, 'page', nextPage.toString())}
                className="usa-pagination__link usa-pagination__next-page"
                aria-label="Next page">
                <span className="usa-pagination__link-text">
                  {i18n.t("nextLabel")}
                </span>
                <Icon.NavigateNext />
              </Link>
            )}
          </li>
        )}
      </ul>
    </nav>
  );
};
