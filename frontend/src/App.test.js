import React from 'react';
import { render } from '@testing-library/react';
import App from './App';

test('renders frontend is up', () => {
  const { getByText } = render(<App />);
  const linkElement = getByText(/Frontend App is running/i);
  expect(linkElement).toBeInTheDocument();
});
