import React, { useState, useEffect } from 'react';
import { Container, Typography, TextField, Button, Slider, Box, Paper } from '@mui/material';
import { styled } from '@mui/system';
import { backend } from 'declarations/backend';

const StyledPaper = styled(Paper)(({ theme }) => ({
  padding: theme.spacing(3),
  marginBottom: theme.spacing(3),
}));

interface Person {
  id: bigint;
  name: string;
  percentage: number;
  amount: number | null;
}

function App() {
  const [billAmount, setBillAmount] = useState<number>(0);
  const [people, setPeople] = useState<Person[]>([]);
  const [newPersonName, setNewPersonName] = useState<string>('');
  const [totalPercentage, setTotalPercentage] = useState<number>(0);

  useEffect(() => {
    fetchBillSplit();
  }, []);

  const fetchBillSplit = async () => {
    try {
      const result = await backend.getBillSplit();
      setBillAmount(Number(result.totalAmount));
      setPeople(result.people.map(p => ({
        ...p,
        id: BigInt(p.id),
        percentage: Number(p.percentage),
        amount: p.amount ? Number(p.amount) : null
      })));
      setTotalPercentage(Number(result.totalPercentage));
    } catch (error) {
      console.error('Error fetching bill split:', error);
    }
  };

  const handleBillAmountChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const amount = parseFloat(event.target.value);
    setBillAmount(amount);
    try {
      // First, calculate new amounts without updating the backend state
      const updatedPeople = await backend.calculateAmounts(amount);
      setPeople(updatedPeople.map(p => ({
        ...p,
        id: BigInt(p.id),
        percentage: Number(p.percentage),
        amount: p.amount ? Number(p.amount) : null
      })));
      
      // Then, update the backend state asynchronously
      await backend.setBillAmount(amount);
    } catch (error) {
      console.error('Error updating bill amount:', error);
    }
  };

  const handleAddPerson = async () => {
    if (newPersonName.trim()) {
      try {
        await backend.addPerson(newPersonName);
        setNewPersonName('');
        fetchBillSplit();
      } catch (error) {
        console.error('Error adding person:', error);
      }
    }
  };

  const handleRemovePerson = async (id: bigint) => {
    try {
      await backend.removePerson(id);
      fetchBillSplit();
    } catch (error) {
      console.error('Error removing person:', error);
    }
  };

  const handlePercentageChange = async (id: bigint, newValue: number) => {
    try {
      await backend.updatePercentage(id, newValue);
      fetchBillSplit();
    } catch (error) {
      console.error('Error updating percentage:', error);
    }
  };

  return (
    <Container maxWidth="sm">
      <Typography variant="h4" component="h1" gutterBottom>
        Bill Splitter
      </Typography>
      <StyledPaper>
        <TextField
          label="Bill Amount"
          type="number"
          value={billAmount}
          onChange={handleBillAmountChange}
          fullWidth
          margin="normal"
        />
      </StyledPaper>
      <StyledPaper>
        <Typography variant="h6" gutterBottom>
          People
        </Typography>
        {people.map((person) => (
          <Box key={person.id.toString()} mb={2}>
            <Typography variant="subtitle1">{person.name}</Typography>
            <Slider
              value={person.percentage}
              onChange={(_, newValue) => handlePercentageChange(person.id, newValue as number)}
              aria-labelledby="continuous-slider"
              valueLabelDisplay="auto"
              min={0}
              max={100}
            />
            <Typography variant="body2">
              {person.percentage.toFixed(2)}% - ${person.amount?.toFixed(2) || '0.00'}
            </Typography>
            <Button onClick={() => handleRemovePerson(person.id)} size="small" color="secondary">
              Remove
            </Button>
          </Box>
        ))}
        <Box display="flex" alignItems="center">
          <TextField
            label="New Person"
            value={newPersonName}
            onChange={(e) => setNewPersonName(e.target.value)}
            margin="normal"
          />
          <Button onClick={handleAddPerson} variant="contained" color="primary" style={{ marginLeft: '1rem' }}>
            Add Person
          </Button>
        </Box>
      </StyledPaper>
      <StyledPaper>
        <Typography variant="h6" gutterBottom>
          Total
        </Typography>
        <Typography variant="body1">
          Total Percentage: {totalPercentage.toFixed(2)}%
        </Typography>
        <Typography variant="body1">
          Remaining: {(100 - totalPercentage).toFixed(2)}%
        </Typography>
      </StyledPaper>
    </Container>
  );
}

export default App;
