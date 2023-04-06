import { render, screen, fireEvent } from '@testing-library/react'
import React from 'react'

import { UswdsPagination } from '../components/Pagination/UswdsPagination';

describe('Pagination component', () => {
  const testPages = 24
  const testThreePages = 3
  const testSevenPages = 7
  const testPathname = '/test-pathname'

  it('renders pagination for a list of pages', () => {
    render(
      <UswdsPagination
        totalPages={testPages}
        currentPage={10}
        pathname={testPathname}
      />
    )
  })

  it('only renders the maximum number of slots', () => {
    render(
      <UswdsPagination
        totalPages={testPages}
        currentPage={10}
        pathname={testPathname}
      />
    )
    expect(screen.getAllByRole('listitem')).toHaveLength(7) // overflow slots don't count
  })

  it('renders pagination when the first page is current', () => {
    render(
      <UswdsPagination
        totalPages={testPages}
        currentPage={1}
        pathname={testPathname}
      />
    )
  })

  it('renders pagination when the last page is current', () => {
    render(
      <UswdsPagination
        totalPages={testPages}
        currentPage={24}
        pathname={testPathname}
      />
    )
  })

  it('renders overflow at the beginning and end when current page is in the middle', () => {
    render(
      <UswdsPagination
        totalPages={testPages}
        currentPage={10}
        pathname={testPathname}
      />
    )
    expect(screen.getAllByText('…')).toHaveLength(2)
  })

  it('renders overflow at the end when at the beginning of the pages', () => {
    render(
      <UswdsPagination
        totalPages={testPages}
        currentPage={3}
        pathname={testPathname}
      />
    )
  })

  it('renders overflow at the beginning when at the end of the pages', () => {
    render(
      <UswdsPagination
        totalPages={testPages}
        currentPage={21}
        pathname={testPathname}
      />
    )
    expect(screen.getAllByText('…')).toHaveLength(1)
  })

  it('can click onClickNext, onClickPrevious and onClickPagenumber', () => {
    const mockOnClickNext = jest.fn()
    const mockOnClickPrevious = jest.fn()
    const mockOnClickPageNumber = jest.fn()

    const { getByTestId, getAllByTestId } = render(
      <UswdsPagination
        totalPages={testPages}
        currentPage={21}
        pathname={testPathname}
        onClickPrevious={mockOnClickPrevious}
        onClickNext={mockOnClickNext}
        onClickPageNumber={mockOnClickPageNumber}
      />
    )

    fireEvent.click(getByTestId('pagination-next'))
    expect(mockOnClickNext).toHaveBeenCalledTimes(1)

    fireEvent.click(getByTestId('pagination-previous'))
    expect(mockOnClickPrevious).toHaveBeenCalledTimes(1)

    const allPageNumbers = getAllByTestId('pagination-page-number')
    fireEvent.click(allPageNumbers[0])
    expect(mockOnClickPageNumber).toHaveBeenCalledTimes(1)
  })

  describe('for fewer pages than the max slots', () => {
    it('renders pagination with no overflow', () => {
      render(
        <UswdsPagination
          totalPages={testThreePages}
          currentPage={2}
          pathname={testPathname}
        />
      )
      expect(screen.getAllByRole('listitem')).toHaveLength(5)
      expect(screen.queryAllByText('…')).toHaveLength(0)
    })

    it('renders pagination with no overflow', () => {
      render(
        <UswdsPagination
          totalPages={testSevenPages}
          currentPage={4}
          pathname={testPathname}
        />
      )
      expect(screen.getAllByRole('listitem')).toHaveLength(9)
      expect(screen.queryAllByText('…')).toHaveLength(0)
    })
  })

  describe('with a custom slot number passed in', () => {
    it('only renders the maximum number of slots', () => {
      render(
        <UswdsPagination
          totalPages={testPages}
          currentPage={10}
          pathname={testPathname}
          maxSlots={10}
        />
      )
      expect(screen.getAllByRole('listitem')).toHaveLength(10)
    })
  })
})
