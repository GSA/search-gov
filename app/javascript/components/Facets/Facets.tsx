/* eslint-disable camelcase */
/* eslint-disable quote-props */
import React, { useContext, useEffect } from 'react';
import styled from 'styled-components';
import { Accordion, DateRangePicker, Tag } from '@trussworks/react-uswds';

import { StyleContext } from '../../contexts/StyleContext';
import { FontsAndColors  } from '../SearchResultsLayout';
import { checkColorContrastAndUpdateStyle } from '../../utils';
import { FacetsLabel } from './FacetsLabel';

import './Facets.css';

interface FacetsProps {
  aggregations?: AggregationData[];
}

interface AggregationItem {
  agg_key: string;
  doc_count: number;
}

type AggregationCategory = string;

type AggregationData = {
  [key in AggregationCategory]: AggregationItem[];
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
  }

  .clear-results-button{
    color: ${(props) => props.styles.buttonBackgroundColor};
  }
  .usa-search__facets-clone-icon {
    fill: ${(props) => props.styles.buttonBackgroundColor};
  }
  
`;

type HeadingLevel = 'h4'; 

const getAccordionItems = (aggregationsData: any) => {
  console.log({ aggregationsData });
  return aggregationsData.map((aggregation: AggregationItem) => {
    console.log({ aggregation });
    return {
      title: Object.keys(aggregation)[0],
      expanded: true,
      id: Object.keys(aggregation)[0].replace(/\s+/g, ''),
      headingLevel: 'h4' as HeadingLevel,
      content: getAccordionItemContent(aggregation)
    };
  });
};

const getAccordionItemContent = (aggregation: any) => {
  return (
    <fieldset className="usa-fieldset">
      {Object.values(aggregation).map((filters:any) => {
        console.log({ filters });
        return (
          filters.map((filter:AggregationItem, index:number) => {
            console.log({ filter });
            return (
              <div className="usa-checkbox" key={index}>
                <input
                  className="usa-checkbox__input"
                  type="checkbox"
                  name={Object.keys(aggregation)[0]}
                  value={filter.agg_key}
                  defaultChecked={true}
                />
                <label className="usa-checkbox__label">{filter.agg_key} <Tag>{filter.doc_count}</Tag></label>
              </div>
            );
          })
        );
      })}
    </fieldset>
  );
};

const getAggregations = (aggregations: AggregationData[]) => {
  // To remove the dummy aggregations with integration once backend starts sending the data
  const dummyAggregationsData = [
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
          agg_key: 'PDF',
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

  const aggregationsData = aggregations || dummyAggregationsData;
  
  return (
    <Accordion 
      bordered={false} 
      items={getAccordionItems(aggregationsData)} 
    />
  );
};

export const Facets = ({ aggregations }: FacetsProps) => {
  const styles = useContext(StyleContext);
  
  useEffect(() => {
    checkColorContrastAndUpdateStyle({
      backgroundItemClass: '.serp-result-wrapper',
      foregroundItemClass: '.clear-results-button',
      isForegroundItemBtn: true
    });

    checkColorContrastAndUpdateStyle({
      backgroundItemClass: '.serp-facets-wrapper .see-results-button',
      foregroundItemClass: '.serp-facets-wrapper .see-results-button',
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

        {aggregations && getAggregations(aggregations)}

        <Accordion bordered={false} items={dateRangeItems} />
      </div>
      <div className="facets-action-btn-wrapper">
        <ul className="usa-button-group">
          <li className="usa-button-group__item clear-results-button-wrapper">
            <button className="usa-button usa-button--unstyled clear-results-button" type="button">
              Clear
            </button>
          </li>
          <li className="usa-button-group__item">
            <button type="button" className="usa-button see-results-button">See Results</button>
          </li>
        </ul>
      </div>
    </StyledWrapper>
  );
};
