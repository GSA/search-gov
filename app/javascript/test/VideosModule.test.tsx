/* eslint-disable camelcase */

import '@testing-library/jest-dom';
import { fireEvent, render, screen } from '@testing-library/react';
import React from 'react';
import { I18n } from 'i18n-js';
import { enableFetchMocks } from 'jest-fetch-mock';
enableFetchMocks();

import { VideosModule } from '../components/Results/Videos/VideosModule';
import { LanguageContext } from '../contexts/LanguageContext';

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

describe('Videos component', () => {
  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json'
  };
  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({})
    })
  ) as jest.Mock;
  const locale = {
    en: {
      searches: {
        moreNewsAboutQuery: 'More videos about %{query}'
      }
    }
  };
  jest.mock('i18n-js', () => {
    return jest.requireActual('i18n-js/dist/require/index');
  });
  const i18n = new I18n(locale);
  const videos = [
    {
      link: 'string',
      title: 'image title',
      description: 'string',
      publishedAt: '2 days ago',
      youtubeThumbnailUrl: 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      duration: '2:50'
    }
  ];
  
  it('renders videos component', () => {
    render(
      <VideosModule affiliate='test_affiliate' videos={videos} query='nasa' vertical='web'/>
    );
  });

  it('shows video image and title', () => {
    render(
      <VideosModule affiliate='test_affiliate' videos={videos} query='nasa' vertical='web'/>
    );
    const img = Array.from(document.getElementsByClassName('result-image')).pop() as HTMLImageElement;
    expect(img).toHaveAttribute('src', 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60');
    expect(img).toHaveAttribute('alt', 'image title');
  });

  it('calls fetch with correct video module click data', () => {
    render(<VideosModule affiliate='test_affiliate' videos={videos} query='nasa' vertical='web'/>);

    const link = screen.getByText(/image title/i);
    fireEvent.click(link);
    const clickBody = {
      affiliate: 'test_affiliate',
      url: 'string',
      module_code: 'VIDS',
      position: 1,
      query: 'nasa',
      vertical: 'web'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it('calls fetch with correct videos module click data for More videos about link', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <VideosModule affiliate='test_affiliate' videos={videos}  videosUrl='/search/news?affiliate=test_affiliate&channel=3&query=nasa' query='nasa' vertical='web'/>
      </LanguageContext.Provider>
    );

    const link = screen.getByText(/More videos about nasa/i);
    fireEvent.click(link);
    const clickBody = {
      affiliate: 'test_affiliate',
      url: 'http://localhost/search/news?affiliate=test_affiliate&channel=3&query=nasa',
      module_code: 'VIDS',
      position: videos.length + 1,
      query: 'nasa',
      vertical: 'web'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });
});
