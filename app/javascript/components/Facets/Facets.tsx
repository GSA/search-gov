/* eslint-disable camelcase */
/* eslint-disable quote-props */
import React, { useContext, useEffect, useState } from 'react';
import styled from 'styled-components';
import { darken } from 'polished';
import { Accordion, DateRangePicker, Tag, Checkbox } from '@trussworks/react-uswds';

import { StyleContext } from '../../contexts/StyleContext';
import { FontsAndColors  } from '../SearchResultsLayout';
import { checkColorContrastAndUpdateStyle, getFacetsQueryParamString, loadQueryUrl, getSelectedAggregationsFromUrlParams, getDefaultCheckedFacet } from '../../utils';
import { FacetsLabel } from './FacetsLabel';

import './Facets.css';

interface FacetsProps {
  aggregations?: AggregationData[];
}

interface AggregationItem {
  agg_key: string;
  doc_count: number;
}

type AggregationData = {
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

const dummyAggregationsData: AggregationData[] = [
  {
    'Audience': [
      {
        agg_key: 'Small business',
        doc_count: 1024
      },
      {
        agg_key: 'Real estate',
        doc_count: 1234
      },
      {
        agg_key: 'Technologists',
        doc_count: 1764
      },
      {
        agg_key: 'Factories',
        doc_count: 1298
      }
    ]
  },
  {
    'Content Type': [
      {
        agg_key: 'Press release',
        doc_count: 2876
      },
      {
        agg_key: 'Blogs',
        doc_count: 1923
      },
      {
        agg_key: 'Policies',
        doc_count: 1244
      },
      {
        agg_key: 'Directives',
        doc_count: 876
      }
    ]
  },
  {
    'File Type': [
      {
        agg_key: 'CSV',
        doc_count: 23
      },
      {
        agg_key: 'Excel',
        doc_count: 76
      },
      {
        agg_key: 'Word',
        doc_count: 11
      },
      {
        agg_key: 'Text',
        doc_count: 12
      }
    ]
  },
  {
    'Tags': [
      {
        agg_key: 'Contracts',
        doc_count: 703
      },
      {
        agg_key: 'BPA',
        doc_count: 22
      }
    ]
  }
];

const getAggregationsFromProps = (inputArray: AggregationData[]) => {
  const outputArray: any = {};

  inputArray.forEach((item: any) => {
    for (const key in item) {
      if (Object.prototype.hasOwnProperty.call(item, key)) {
        outputArray[key] = item[key].map((innerItem: any) => innerItem.agg_key);
      }
    }
  });

  return outputArray;
};

export const Facets = ({ aggregations }: FacetsProps) => {
  const styles = useContext(StyleContext);
  const [selectedIds, setSelectedIds] = useState<any>({});

  const aggregationsProps = getAggregationsFromProps(dummyAggregationsData);
  const { aggregationsSelected, nonAggregations } = getSelectedAggregationsFromUrlParams(aggregationsProps);
  
  const handleCheckboxChange = (event:any) => {
    const filterVal  = event.target.value;
    const filterName = event.target.name;

    if (event.target.checked) {
      if (selectedIds[filterName]!==undefined) {
        selectedIds[filterName].push(filterVal);
      } else {
        selectedIds[filterName] = [filterVal];
      }
    } else {
      selectedIds[filterName] = selectedIds[filterName].filter((id: string) => id !== filterVal);
    }

    setSelectedIds(selectedIds);
  };

  const getAccordionItemContent = (aggregation: any) => {
    return (
      <fieldset className="usa-fieldset">
        {Object.values(aggregation).map((filters: any) => {
          return (
            filters.map((filter: AggregationItem, index: number) => {
              return (
                <div className="usa-checkbox" key={index} >
                  <Checkbox 
                    id={index+filter.agg_key} 
                    data-testid={index+filter.agg_key}
                    label={<>{filter.agg_key} <Tag>{filter.doc_count}</Tag></>}
                    name={Object.keys(aggregation)[0]} 
                    value={filter.agg_key}
                    // defaultChecked={(() => {
                    //   const hasFilterLabel = Object.keys(aggregation)[0] in aggregationsSelected;
                    //   if (hasFilterLabel === false)
                    //     return false;

                    //   const hasFilterValue = aggregationsSelected[Object.keys(aggregation)[0]].includes(filter.agg_key);
                    //   if (hasFilterValue === false)
                    //     return false;

                    //   return true;
                    // })()} 
                    defaultChecked={getDefaultCheckedFacet(filter, aggregation, aggregationsSelected)}
                    onChange={
                      (event) => handleCheckboxChange(event)
                    }
                  />
                </div>
              );
            })
          );
        })}
      </fieldset>
    );
  };

  const getAccordionItems = (aggregationsData: any) => {
    return aggregationsData.map((aggregation: AggregationItem) => {
      return {
        title: Object.keys(aggregation)[0],
        expanded: true,
        id: Object.keys(aggregation)[0].replace(/\s+/g, ''),
        headingLevel: 'h4' as HeadingLevel,
        content: getAccordionItemContent(aggregation)
      };
    });
  };

  const getAggregations = (aggregations?: AggregationData[]) => {
    // To remove the dummy aggregations with integration once backend starts sending the data
    const aggregationsData = aggregations || dummyAggregationsData;
    return (
      <Accordion 
        bordered={false} 
        items={getAccordionItems(aggregationsData)} 
      />
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
              // onClick={() => loadQueryUrl(getFacetsQueryParamString(nonAggregations))}
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
