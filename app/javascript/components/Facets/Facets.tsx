/* eslint-disable camelcase */
/* eslint-disable quote-props */
import React, { useContext, useEffect, useState } from 'react';
import styled from 'styled-components';
import { darken } from 'polished';
import { Accordion, DateRangePicker, Tag, Checkbox } from '@trussworks/react-uswds';

import { StyleContext } from '../../contexts/StyleContext';
import { LanguageContext } from '../../contexts/LanguageContext';
import { FontsAndColors  } from '../SearchResultsLayout';
import { checkColorContrastAndUpdateStyle, getFacetsQueryParamString, loadQueryUrl, getSelectedAggregationsFromUrlParams, getDefaultCheckedFacet } from '../../utils';
import { FacetsLabel } from './FacetsLabel';

import { camelToSnake } from '../../utils';

import './Facets.css';

interface FacetsProps {
  aggregations: AggregationData[];
}

interface AggregationItem {
  aggKey: string;
  docCount: number;
}

export type AggregationData = {
  [key in string]: AggregationItem[];
}

const StyledWrapper = styled.div.attrs<{ styles: FontsAndColors; }>((props) => ({
  styles: props.styles
}))`
  .usa-accordion__button {
    color: ${(props) => props.styles.sectionTitleColor};
  }

  .serp-facets-wrapper .usa-tag{
    color: ${(props) => props.styles.resultTitleColor};
  }

  .see-results-button {
    background: ${(props) => props.styles.buttonBackgroundColor};
    &:hover {
      background-color: ${(props) => darken(0.10, props.styles.buttonBackgroundColor)};
    }
  }

  .clear-results-button{
    color: ${(props) => props.styles.buttonBackgroundColor};
  }
  .usa-search__facets-close-icon {
    fill: ${(props) => props.styles.buttonBackgroundColor};
  }

`;

type HeadingLevel = 'h4';

const getAggregationsFromProps = (inputArray: AggregationData[]) => {
  type aggregationsFromPropsType = {
    [key: string]: string[];
  };

  const aggregationsFromProps: aggregationsFromPropsType = {};

  inputArray.forEach((item: AggregationData) => {
    for (const key in item) {
      if (Object.prototype.hasOwnProperty.call(item, key)) {
        aggregationsFromProps[camelToSnake(key)] = item[key].map((innerItem: AggregationItem) => innerItem.aggKey);
      }
    }
  });

  return aggregationsFromProps;
};

export const Facets = ({ aggregations }: FacetsProps) => {
  const styles = useContext(StyleContext);
  const i18n = useContext(LanguageContext);
  const [selectedIds, setSelectedIds] = useState<Record<string, string[]>>({});

  const aggregationsProps = getAggregationsFromProps(aggregations);
  const { aggregationsSelected, nonAggregations } =
    getSelectedAggregationsFromUrlParams(aggregationsProps);

  const handleCheckboxChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const filterVal = event.target.value;
    const filterName = event.target.name;

    if (event.target.checked) {
      if (selectedIds[filterName] !== undefined) {
        selectedIds[filterName].push(filterVal);
      } else {
        selectedIds[filterName] = [filterVal];
      }
    } else {
      selectedIds[filterName] = selectedIds[filterName].filter(
        (id: string) => id !== filterVal,
      );
    }
    setSelectedIds(selectedIds);
  };

  const getAccordionItemContent = (
    aggregation: Record<string, AggregationItem[]>,
  ) => {
    return (
      <fieldset className="usa-fieldset">
        {Object.values(aggregation).map((filters: AggregationItem[]) => {
          return filters.map((filter: AggregationItem, index: number) => {
            return (
              <div className="usa-checkbox" key={index}>
                <Checkbox
                  id={index + filter.aggKey}
                  data-testid={index + filter.aggKey}
                  label={
                    <>
                      {filter.aggKey} <Tag>{filter.docCount}</Tag>
                    </>
                  }
                  name={camelToSnake(Object.keys(aggregation)[0])}
                  //name={Object.keys(aggregation)[0]}
                  value={filter.aggKey}
                  defaultChecked={getDefaultCheckedFacet(
                    filter,
                    aggregation,
                    aggregationsSelected,
                  )}
                  onChange={(event) => handleCheckboxChange(event)}
                />
              </div>
            );
          });
        })}
      </fieldset>
    );
  };

  const getAccordionItems = (aggregationsData: AggregationData[]) => {
    return aggregationsData.map((aggregation: AggregationData) => {
      return {
        title: i18n.t(`facets.${Object.keys(aggregation)[0]}`),
        expanded: true,
        id: Object.keys(aggregation)[0].replace(/\s+/g, ''),
        headingLevel: 'h4' as HeadingLevel,
        content: getAccordionItemContent(aggregation)
      };
    });
  };

  const getAggregations = (aggregations: AggregationData[]) => {
    return (
      <Accordion bordered={false} items={getAccordionItems(aggregations)} />
    );
  };

  useEffect(() => {
    setSelectedIds(aggregationsSelected);

    checkColorContrastAndUpdateStyle({
      backgroundItemClass: '.serp-result-wrapper',
      foregroundItemClass: '.clear-results-button',
      isForegroundItemBtn: true
    });

    checkColorContrastAndUpdateStyle({
      backgroundItemClass: '.facets-action-btn-wrapper .see-results-button',
      foregroundItemClass: '.facets-action-btn-wrapper .see-results-button',
      isForegroundItemBtn: true
    });
  }, []);

  const dateRangeItems = [
    {
      title: 'Date Range',
      content: (
        <fieldset className="usa-fieldset">
          <div className="usa-radio">
            <input
              className="usa-radio__input"
              type="radio"
              name="date_range"
              value="last_year"
              defaultChecked={true}
            />
            <label className="usa-radio__label">Last year</label>
          </div>
          <div className="usa-radio">
            <input
              className="usa-radio__input"
              type="radio"
              name="date_range"
              value="last_month"
            />
            <label className="usa-radio__label">Last month</label>
          </div>
          <div className="usa-radio">
            <input
              className="usa-radio__input"
              type="radio"
              name="date_range"
              value="last_week"
            />
            <label className="usa-radio__label">Last week</label>
          </div>
          <div className="usa-radio">
            <input
              className="usa-radio__input"
              type="radio"
              name="date_range"
              value="custom_date"
            />
            <label className="usa-radio__label">Custom date range</label>
          </div>
          <DateRangePicker
            startDateHint="mm/dd/yyyy"
            startDateLabel="Date from"
            startDatePickerProps={{
              disabled: false,
              id: 'event-date-start',
              name: 'event-date-start'
            }}
            endDateHint="mm/dd/yyyy"
            endDateLabel="Date to"
            endDatePickerProps={{
              disabled: false,
              id: 'event-date-end',
              name: 'event-date-end'
            }}
          />
        </fieldset>
      ),
      expanded: true,
      id: 'dateRangeItems',
      headingLevel: 'h4' as HeadingLevel
    }
  ];

  return (
    <StyledWrapper styles={styles}>
      <div className="serp-facets-wrapper">
        <FacetsLabel />

        {getAggregations(aggregations)}

        <Accordion bordered={false} items={dateRangeItems} />
      </div>

      <div className="facets-action-btn-wrapper">
        <ul className="usa-button-group">
          <li className="usa-button-group__item clear-results-button-wrapper">
            <button
              className="usa-button usa-button--unstyled clear-results-button"
              type="button"
              onClick={() => loadQueryUrl(getFacetsQueryParamString(nonAggregations))}
            >
              Clear
            </button>
          </li>
          <li className="usa-button-group__item">
            <button
              type="button"
              className="usa-button see-results-button"
              onClick={() => loadQueryUrl(getFacetsQueryParamString({ ...nonAggregations, ...selectedIds }))}
            >
              See Results
            </button>
          </li>
        </ul>
      </div>
    </StyledWrapper>
  );
};
