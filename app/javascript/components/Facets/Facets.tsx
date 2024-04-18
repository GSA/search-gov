import React, { useContext } from 'react';
import styled from 'styled-components';
import { Accordion, DateRangePicker, Tag } from '@trussworks/react-uswds';

import { StyleContext } from '../../contexts/StyleContext';
import { FontsAndColors  } from '../SearchResultsLayout';

import './Facets.css';

const searchFilterSvgIcon = () => {
  return (
    <svg role="img" xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24">
      <title>Filter</title>
      <path className="search-filer-icon" fill="#005EA2" d="M4.25 5.61C6.27 8.2 10 13 10 13v6c0 .55.45 1 1 1h2c.55 0 1-.45 1-1v-6s3.72-4.8 5.74-7.39A.998.998 0 0 0 18.95 4H5.04c-.83 0-1.3.95-.79 1.61z"/>
    </svg>
  );
};

const StyledWrapper = styled.div.attrs<{ styles: FontsAndColors; }>((props) => ({
  styles: props.styles
}))`

	path.search-filer-icon {
		fill: ${(props) => props.styles.buttonBackgroundColor};
	}

  .usa-accordion__button {
    color: ${(props) => props.styles.searchTabNavigationLinkColor};
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
`;

type HeadingLevel = "h1" | "h2" | "h3" | "h4" | "h5" | "h6"; 

export const Facets = () => {
	const styles = useContext(StyleContext);

	const audienceItems = [
		{
			title: 'Audience',
			content: (
				<fieldset className="usa-fieldset">
					<div className="usa-checkbox">
						<input
							className="usa-checkbox__input"
							id="check-historical-truth"
							type="checkbox"
							name="audience"
							value="small_business"
							defaultChecked={true}
						/>
						<label className="usa-checkbox__label">Small business <Tag>1024</Tag></label>
					</div>
					<div className="usa-checkbox">
						<input
							className="usa-checkbox__input"
							id="check-historical-douglass"
							type="checkbox"
							name="audience"
							value="real_estate"
						/>
						<label className="usa-checkbox__label">Real estate <Tag>1234</Tag></label>
					</div>
					<div className="usa-checkbox">
						<input
							className="usa-checkbox__input"
							id="check-historical-washington"
							type="checkbox"
							name="audience"
							value="technologists"
						/>
						<label className="usa-checkbox__label">Technologists <Tag>1764</Tag></label>
					</div>
					<div className="usa-checkbox">
						<input
							className="usa-checkbox__input"
							id="check-historical-carver"
							type="checkbox"
							name="audience"
							value="real-estate"
						/>
						<label className="usa-checkbox__label">Real estate <Tag>1298</Tag></label>
					</div>
				</fieldset>
			),
			expanded: true,
			id: 'audienceItems',
			headingLevel: 'h4' as HeadingLevel,
		}
	];

	const contentTypeItems = [
		{
			title: 'Content Type',
			content: (
				<fieldset className="usa-fieldset">
					<div className="usa-checkbox">
						<input
							className="usa-checkbox__input"
							id="check-historical-truth"
							type="checkbox"
							name="content_type"
							value="press_release"
							defaultChecked={true}
						/>
						<label className="usa-checkbox__label">Press release <Tag>2876</Tag></label>
					</div>
					<div className="usa-checkbox">
						<input
							className="usa-checkbox__input"
							id="check-historical-douglass"
							type="checkbox"
							name="content_type"
							value="blogs"
						/>
						<label className="usa-checkbox__label">Blogs <Tag>1923</Tag></label>
					</div>
					<div className="usa-checkbox">
						<input
							className="usa-checkbox__input"
							id="check-historical-washington"
							type="checkbox"
							name="content_type"
							value="policies"
						/>
						<label className="usa-checkbox__label">Policies <Tag>1244</Tag></label>
					</div>
					<div className="usa-checkbox">
						<input
							className="usa-checkbox__input"
							id="check-historical-carver"
							type="checkbox"
							name="content_type"
							value="directives"
						/>
						<label className="usa-checkbox__label">Directives <Tag>876</Tag></label>
					</div>
				</fieldset>
			),
			expanded: true,
			id: 'contentTypeItems',
			headingLevel: 'h4' as HeadingLevel,
		}
	];

	const fileTypeItems = [
		{
			title: 'File Type',
			content: (
				<fieldset className="usa-fieldset">
					<div className="usa-checkbox">
						<input
							className="usa-checkbox__input"
							id="check-historical-truth"
							type="checkbox"
							name="file_type"
							value="pdf"
							defaultChecked={true}
						/>
						<label className="usa-checkbox__label">PDF <Tag>23</Tag></label>
					</div>
					<div className="usa-checkbox">
						<input
							className="usa-checkbox__input"
							id="check-historical-douglass"
							type="checkbox"
							name="file_type"
							value="excel"
						/>
						<label className="usa-checkbox__label">Excel <Tag>76</Tag></label>
					</div>
					<div className="usa-checkbox">
						<input
							className="usa-checkbox__input"
							id="check-historical-washington"
							type="checkbox"
							name="file_type"
							value="word"
						/>
						<label className="usa-checkbox__label">Word <Tag>11</Tag></label>
					</div>
					<div className="usa-checkbox">
						<input
							className="usa-checkbox__input"
							id="check-historical-carver"
							type="checkbox"
							name="file_type"
							value="text"
						/>
						<label className="usa-checkbox__label">Text <Tag>123</Tag></label>
					</div>
				</fieldset>
			),
			expanded: true,
			id: 'fileTypeItems',
			headingLevel: 'h4' as HeadingLevel,
		}
	];

	const tagsItems = [
		{
			title: 'Tags',
			content: (
				<fieldset className="usa-fieldset">
					<div className="usa-checkbox">
						<input
							className="usa-checkbox__input"
							id="check-historical-truth"
							type="checkbox"
							name="tags"
							value="contracts"
							defaultChecked={true}
						/>
						<label className="usa-checkbox__label">Contracts <Tag>703</Tag></label>
					</div>
					<div className="usa-checkbox">
						<input
							className="usa-checkbox__input"
							id="check-historical-douglass"
							type="checkbox"
							name="tags"
							value="bpa"
						/>
						<label className="usa-checkbox__label">BPA <Tag>232</Tag></label>
					</div>
				</fieldset>
			),
			expanded: true,
			id: 'tagsItems',
			headingLevel: 'h4' as HeadingLevel,
		}
	];

	const dateRangeItems = [
		{
			title: 'Date Range',
			content: (
				<fieldset className="usa-fieldset">
					<div className="usa-radio">
						<input
							className="usa-radio__input"
							id="historical-truth"
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
							id="historical-douglass"
							type="radio"
							name="date_range"
							value="last_month"
						/>
						<label className="usa-radio__label">Last month</label>
					</div>
					<div className="usa-radio">
						<input
							className="usa-radio__input"
							id="historical-washington"
							type="radio"
							name="date_range"
							value="last_week"
						/>
						<label className="usa-radio__label">Last week</label>
					</div>
					<div className="usa-radio">
						<input
							className="usa-radio__input"
							id="historical-carver"
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
			headingLevel: 'h4' as HeadingLevel,
		}
	];

  return (
		 <StyledWrapper styles={styles}>
			<div className="serp-facets-wrapper">
				<h3 className="filter-heading">
					{searchFilterSvgIcon()} 
					<span className="filter-heading-label">Filter search</span>
				</h3>
				<Accordion bordered={false} items={audienceItems} />
				<Accordion bordered={false} items={contentTypeItems} />
				<Accordion bordered={false} items={fileTypeItems} />
				<Accordion bordered={false} items={tagsItems} />
				<Accordion bordered={false} items={dateRangeItems} />

				<ul className="usa-button-group">
					<li className="usa-button-group__item">
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
